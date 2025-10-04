# Questions Import System

This document describes the mass import system for questions from CSV files (exported from Google Sheets).

## Overview

The import system allows users to bulk import questions of all supported types from CSV files. It includes comprehensive validation, error reporting, and preview functionality.

## Features

- **All Question Types Supported**: written, multiple_choice, calculation, matching, cloze, ordering, ranking, diagram_label, image_occlusion, composite, markdown
- **Preview Mode**: Validate data before importing
- **Comprehensive Validation**: Multi-level validation with detailed error messages
- **Topic/Source Management**: Automatically creates topics and sources as needed
- **Transaction Safety**: All-or-nothing import with rollback on errors
- **User-Friendly Interface**: Clear instructions and error reporting

## Getting Started

### 1. Download Template

Visit `/questions/import` and download the CSV template file.

### 2. Fill Template

Use the template to create your questions following the column structure described below.

### 3. Import Questions

Upload your CSV file and choose preview or full import.

## CSV Column Structure

### Required Columns

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `topic` | String | Topic name (will create if doesn't exist) | "Physics - MOSFETs & Circuits" |
| `question_type` | String | One of the supported question types | "written", "multiple_choice", etc. |
| `content` | String | Question text/content | "Explain how MOSFETs work..." |
| `answer` | String | Expected answer | "MOSFETs have high input impedance..." |
| `points` | Integer | Points value (1-100) | 2 |

### Optional Columns

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `answer_size` | String | Answer space size | "short", "medium", "long" |
| `source` | String | Source name (will create if doesn't exist) | "Feynman Lectures on Physics" |
| `source_reference` | String | Reference within source | "Chapter 14, p.237" |
| `answer_label` | String | For calculation questions | "resistance", "V" |
| `unit` | String | For calculation questions | "MOhm", "V" |

### Type-Specific Columns

#### Multiple Choice Questions
- `options`: Pipe-separated options
  - Example: `"Option A|Option B|Option C|Option D"`

#### Matching Questions
- `left_items`: Pipe-separated left column items
  - Example: `"Ohm (Ω)|Farad (F)|Henry (H)"`
- `right_items`: Pipe-separated right column items
  - Example: `"Resistance|Capacitance|Inductance"`

#### Ordering/Ranking Questions
- `options`: Pipe-separated items to order/rank
  - Example: `"Item 1|Item 2|Item 3"`

#### Diagram Label Questions
- `image`: Image filename (must exist in app/assets/images/)
  - Example: `"MOSFET_symbol.svg"`
- `labels`: Pipe-separated labels
  - Example: `"Gate|Source|Drain"`
- `markers`: JSON array of marker coordinates (optional)
  - Example: `"[{\"x\":25,\"y\":30},{\"x\":75,\"y\":50}]"`

#### Image Occlusion Questions
- `image`: Image filename
  - Example: `"circuit_diagram.svg"`
- `masks`: JSON array of mask coordinates
  - Example: `"[{\"x\":35,\"y\":30,\"w\":25,\"h\":15}]"`

#### Composite Questions
- `parts`: JSON array defining sub-questions
  - Example: `"[{\"type\":\"written\",\"content\":\"Part A\",\"points\":2},{\"type\":\"multiple_choice\",\"content\":\"Part B\",\"options\":[\"A\",\"B\"],\"points\":1}]"`

#### Cloze Questions
- Uses `content` with `[[blank]]` or `{{blank}}` syntax
  - Example: `"In a MOSFET, the gate is [[insulated]] from the channel."`

## Question Types

### Written Questions
Open-ended text questions requiring written responses.

**Required**: topic, question_type="written", content, answer, points

### Multiple Choice Questions
Questions with multiple answer choices.

**Required**: topic, question_type="multiple_choice", content, answer, points, options
**Validation**: At least 2 options required

### Calculation Questions
Mathematical problems requiring calculations.

**Required**: topic, question_type="calculation", content, answer, points
**Recommended**: answer_label, unit

### Matching Questions
Match items from two columns.

**Required**: topic, question_type="matching", content, answer, points, left_items, right_items
**Validation**: Left and right arrays must have same length

### Cloze Questions
Fill-in-the-blank questions.

**Required**: topic, question_type="cloze", content, answer, points
**Note**: Use `[[blank]]` or `{{blank}}` syntax in content

### Ordering Questions
Arrange items in correct sequence.

**Required**: topic, question_type="ordering", content, answer, points, options
**Validation**: At least 2 items required

### Ranking Questions
Rank items by priority or importance.

**Required**: topic, question_type="ranking", content, answer, points, options
**Validation**: At least 2 items required

### Diagram Label Questions
Label parts of a diagram.

**Required**: topic, question_type="diagram_label", content, answer, points, image, labels
**Optional**: markers (JSON array of coordinates)

### Image Occlusion Questions
Identify hidden parts of an image.

**Required**: topic, question_type="image_occlusion", content, answer, points, image
**Optional**: masks (JSON array of coordinates)

### Composite Questions
Multi-part questions with different types.

**Required**: topic, question_type="composite", content, answer, points, parts
**Note**: parts must be valid JSON array

### Markdown Questions
Questions with markdown formatting.

**Required**: topic, question_type="markdown", content, answer, points

## Validation Rules

### General Validation
- All required fields must be present
- Points must be between 1 and 100
- Answer size must be one of: short, medium, long
- Question type must be one of the supported types

### Type-Specific Validation
- **Multiple Choice**: At least 2 options required
- **Matching**: Left and right arrays must have same length, at least 2 pairs
- **Ordering/Ranking**: At least 2 items required
- **Diagram Label**: Image and labels required
- **Image Occlusion**: Image required
- **Composite**: At least one part required, each part must have type, content, and points

### JSON Validation
- Markers and masks must be valid JSON arrays
- Composite parts must be valid JSON array
- Coordinate values must be between 0 and 100

## Error Handling

The import system provides detailed error messages for:
- Missing required fields
- Invalid field values
- Type-specific validation failures
- JSON parsing errors
- Database constraint violations

## Usage Examples

### Basic Written Question
```csv
topic,question_type,content,answer,points,answer_size,source,source_reference
Physics,written,"Explain MOSFET operation","High input impedance",2,short,Feynman Lectures,Ch 14
```

### Multiple Choice Question
```csv
topic,question_type,content,answer,points,answer_size,options
Physics,multiple_choice,"What does Ω represent?","A - Ohms",1,short,"Ohms|Webers|Siemens|Tesla"
```

### Matching Question
```csv
topic,question_type,content,answer,points,left_items,right_items
Electronics,matching,"Match units to quantities","Ohm → Resistance",3,"Ohm (Ω)|Farad (F)|Henry (H)","Resistance|Capacitance|Inductance"
```

### Diagram Label Question
```csv
topic,question_type,content,answer,points,image,labels,markers
Electronics,diagram_label,"Label the MOSFET terminals","Gate Source Drain",2,MOSFET_symbol.svg,"Gate|Source|Drain","[{""x"":25,""y"":30},{""x"":75,""y"":50}]"
```

### Composite Question
```csv
topic,question_type,content,answer,points,parts
Programming,composite,"Answer about Rails","a) MVC; b) Strong params",5,"[{""type"":""written"",""content"":""a) Describe MVC"",""points"":2},{""type"":""multiple_choice"",""content"":""b) What are strong params?"",""options"":[""Security"",""Performance""],""points"":3}]"
```

## API Endpoints

### GET /questions/import
Displays the import page with instructions and file upload form.

### POST /questions/import_csv
Imports questions from uploaded CSV file.

**Parameters:**
- `csv_file`: Uploaded CSV file (required)
- `preview_only`: Boolean, if true only validates without importing

**Response:**
- Success: Redirects to questions index with success message
- Error: Redirects to import page with error message

### POST /questions/import_preview
AJAX endpoint for real-time validation.

**Parameters:**
- `csv_data`: JSON array of CSV rows

**Response:**
- JSON object with validation results

## Testing

The import system includes comprehensive test coverage:

- **Unit Tests**: Individual service classes
- **Integration Tests**: Complete import workflow
- **Request Tests**: Controller actions and error handling

Run tests with:
```bash
bundle exec rspec spec/services/questions_importer_spec.rb
bundle exec rspec spec/services/question_row_parser_spec.rb
bundle exec rspec spec/services/question_type_validator_spec.rb
bundle exec rspec spec/requests/questions_import_spec.rb
bundle exec rspec spec/integration/questions_import_integration_spec.rb
```

## Troubleshooting

### Common Issues

1. **CSV Format Errors**
   - Ensure proper CSV escaping for quotes and commas
   - Use pipe (|) separator for arrays, not commas
   - Validate JSON syntax for complex fields

2. **Image File Errors**
   - Ensure image files exist in app/assets/images/
   - Use correct file extensions (.svg, .png, .jpg)
   - Check file permissions

3. **Validation Errors**
   - Review error messages carefully
   - Check required fields for each question type
   - Validate JSON syntax for markers, masks, and parts

4. **Import Failures**
   - Use preview mode first to catch errors
   - Check database constraints
   - Review transaction rollback messages

### Support

For additional help or to report issues, please refer to the application documentation or contact the development team.
