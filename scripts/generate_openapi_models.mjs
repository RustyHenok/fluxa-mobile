#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const contractPath = path.join(rootDir, 'contracts', 'fluxa-openapi.json');
const outputPath = path.join(
  rootDir,
  'lib',
  'core',
  'models',
  'generated',
  'fluxa_contract_models.dart',
);

const schemaNameMap = new Map([
  ['AuthResponse', 'FluxaSession'],
  ['DashboardSummary', 'FluxaDashboardSummary'],
  ['JobResponse', 'FluxaJob'],
  ['JobResultResponse', 'FluxaJobResult'],
  ['MeResponse', 'FluxaMe'],
  ['ProjectResponse', 'FluxaProject'],
  ['ProjectSummary', 'FluxaProjectSummary'],
  ['TaskAuditListResponse', 'FluxaTaskAuditPage'],
  ['TaskAuditResponse', 'FluxaTaskAuditEntry'],
  ['TaskListResponse', 'FluxaTaskPage'],
  ['TaskResponse', 'FluxaTask'],
  ['TenantMemberResponse', 'FluxaTenantMember'],
  ['TenantMembershipResponse', 'FluxaTenantMembership'],
  ['UserResponse', 'FluxaUser'],
]);

const selectedSchemas = [
  'AuthResponse',
  'DashboardSummary',
  'JobResponse',
  'JobResultResponse',
  'MeResponse',
  'ProjectResponse',
  'ProjectSummary',
  'TaskAuditListResponse',
  'TaskAuditResponse',
  'TaskListResponse',
  'TaskResponse',
  'TenantMemberResponse',
  'TenantMembershipResponse',
  'UserResponse',
];

const spec = JSON.parse(fs.readFileSync(contractPath, 'utf8'));
const schemas = spec?.components?.schemas ?? {};

function assertSchema(name) {
  const schema = schemas[name];
  if (!schema) {
    throw new Error(`Schema not found in contract: ${name}`);
  }
  return schema;
}

function isEnumSchema(name) {
  const schema = assertSchema(name);
  return Array.isArray(schema.enum);
}

function isFreeformSchema(name) {
  const schema = assertSchema(name);
  return schema.type === 'object' && !schema.properties;
}

function toCamelCase(value) {
  return value.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase());
}

function sanitizeFieldName(value) {
  const camel = toCamelCase(value);
  if (camel === 'switch' || camel === 'default') {
    return `${camel}Value`;
  }
  return camel;
}

function classNameForSchema(name) {
  return schemaNameMap.get(name) ?? name;
}

function refNameFromRef(ref) {
  return ref.split('/').pop();
}

function scalarTypeForSchema(schema) {
  if (schema.oneOf) {
    return 'Map<String, dynamic>';
  }

  switch (schema.type) {
    case 'integer':
      return 'int';
    case 'number':
      return 'double';
    case 'boolean':
      return 'bool';
    case 'string':
      return 'String';
    default:
      return 'dynamic';
  }
}

function fallbackForScalarType(type) {
  switch (type) {
    case 'int':
      return '0';
    case 'double':
      return '0.0';
    case 'bool':
      return 'false';
    case 'String':
      return "''";
    default:
      return 'null';
  }
}

function resolveType(schema, nullable = false) {
  if (schema.oneOf) {
    return nullable ? 'Map<String, dynamic>?' : 'Map<String, dynamic>';
  }

  if (schema.$ref) {
    const refName = refNameFromRef(schema.$ref);
    if (isEnumSchema(refName)) {
      return nullable ? 'String?' : 'String';
    }
    if (isFreeformSchema(refName)) {
      return nullable ? 'Map<String, dynamic>?' : 'Map<String, dynamic>';
    }
    return nullable
        ? `${classNameForSchema(refName)}?`
        : classNameForSchema(refName);
  }

  if (schema.type === 'array') {
    const itemType = resolveType(schema.items ?? {}, false);
    return nullable ? `List<${itemType}>?` : `List<${itemType}>`;
  }

  if (schema.type === 'object') {
    return nullable ? 'Map<String, dynamic>?' : 'Map<String, dynamic>';
  }

  const scalarType = scalarTypeForSchema(schema);
  return nullable ? `${scalarType}?` : scalarType;
}

function fromJsonExpression(schema, jsonKey, nullable = false) {
  const access = `json['${jsonKey}']`;

  if (schema.oneOf) {
    return nullable
        ? `${access} == null ? null : Map<String, dynamic>.from(${access} as Map)`
        : `Map<String, dynamic>.from(${access} as Map? ?? const {})`;
  }

  if (schema.$ref) {
    const refName = refNameFromRef(schema.$ref);
    if (isEnumSchema(refName)) {
      return nullable ? `${access} as String?` : `${access} as String? ?? ''`;
    }
    if (isFreeformSchema(refName)) {
      return nullable
          ? `${access} == null ? null : Map<String, dynamic>.from(${access} as Map)`
          : `Map<String, dynamic>.from(${access} as Map? ?? const {})`;
    }

    const className = classNameForSchema(refName);
    return nullable
        ? `${access} == null ? null : ${className}.fromJson(Map<String, dynamic>.from(${access} as Map))`
        : `${className}.fromJson(Map<String, dynamic>.from(${access} as Map? ?? const {}))`;
  }

  if (schema.type === 'array') {
    const items = schema.items ?? {};
    const itemExpression = arrayItemFromJsonExpression(items, 'entry');
    const base = `(${access} as List? ?? const []).map((entry) => ${itemExpression}).toList()`;
    return nullable ? `${access} == null ? null : ${base}` : base;
  }

  if (schema.type === 'object') {
    return nullable
        ? `${access} == null ? null : Map<String, dynamic>.from(${access} as Map)`
        : `Map<String, dynamic>.from(${access} as Map? ?? const {})`;
  }

  const scalarType = scalarTypeForSchema(schema);
  if (nullable) {
    return `${access} as ${scalarType}?`;
  }

  return `${access} as ${scalarType}? ?? ${fallbackForScalarType(scalarType)}`;
}

function arrayItemFromJsonExpression(schema, accessor) {
  if (schema.$ref) {
    const refName = refNameFromRef(schema.$ref);
    if (isEnumSchema(refName)) {
      return `${accessor} as String? ?? ''`;
    }
    if (isFreeformSchema(refName)) {
      return `Map<String, dynamic>.from(${accessor} as Map)`;
    }
    return `${classNameForSchema(refName)}.fromJson(Map<String, dynamic>.from(${accessor} as Map))`;
  }

  if (schema.type === 'object') {
    return `Map<String, dynamic>.from(${accessor} as Map)`;
  }

  if (schema.type === 'array') {
    return `(${accessor} as List? ?? const []).toList()`;
  }

  const scalarType = scalarTypeForSchema(schema);
  return `${accessor} as ${scalarType}? ?? ${fallbackForScalarType(scalarType)}`;
}

function toJsonExpression(schema, fieldName, nullable = false) {
  if (schema.oneOf) {
    return fieldName;
  }

  if (schema.$ref) {
    const refName = refNameFromRef(schema.$ref);
    if (isEnumSchema(refName) || isFreeformSchema(refName)) {
      return fieldName;
    }

    return nullable ? `${fieldName}?.toJson()` : `${fieldName}.toJson()`;
  }

  if (schema.type === 'array') {
    const items = schema.items ?? {};
    const itemExpression = arrayItemToJsonExpression(items, 'entry');
    const base = `${fieldName}.map((entry) => ${itemExpression}).toList()`;
    return nullable ? `${fieldName}?.map((entry) => ${itemExpression}).toList()` : base;
  }

  return fieldName;
}

function arrayItemToJsonExpression(schema, accessor) {
  if (schema.$ref) {
    const refName = refNameFromRef(schema.$ref);
    if (isEnumSchema(refName) || isFreeformSchema(refName)) {
      return accessor;
    }
    return `${accessor}.toJson()`;
  }

  return accessor;
}

function buildClass(schemaName) {
  const schema = assertSchema(schemaName);
  const className = classNameForSchema(schemaName);
  const properties = schema.properties ?? {};
  const required = new Set(schema.required ?? []);
  const entries = Object.entries(properties).map(([jsonKey, propertySchema]) => {
    const fieldName = sanitizeFieldName(jsonKey);
    const isNullable = !required.has(jsonKey) || propertySchema.nullable === true;

    return {
      fieldName,
      jsonKey,
      propertySchema,
      dartType: resolveType(propertySchema, isNullable),
      fromJson: fromJsonExpression(propertySchema, jsonKey, isNullable),
      toJson: toJsonExpression(propertySchema, fieldName, isNullable),
    };
  });

  const constructorArgs = entries
      .map((entry) => `    required this.${entry.fieldName},`)
      .join('\n');
  const fields = entries
      .map((entry) => `  final ${entry.dartType} ${entry.fieldName};`)
      .join('\n');
  const fromJsonAssignments = entries
      .map((entry) => `      ${entry.fieldName}: ${entry.fromJson},`)
      .join('\n');
  const toJsonAssignments = entries
      .map((entry) => `      '${entry.jsonKey}': ${entry.toJson},`)
      .join('\n');

  return `class ${className} {
  const ${className}({
${constructorArgs}
  });

${fields}

  factory ${className}.fromJson(Map<String, dynamic> json) {
    return ${className}(
${fromJsonAssignments}
    );
  }

  Map<String, dynamic> toJson() {
    return {
${toJsonAssignments}
    };
  }
}`;
}

const output = `// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: constant_identifier_names, non_constant_identifier_names

${selectedSchemas.map(buildClass).join('\n\n')}
`;

fs.mkdirSync(path.dirname(outputPath), { recursive: true });
fs.writeFileSync(outputPath, output);
console.log(`Generated Dart contract models at ${outputPath}`);
