# Forms

## Native Constraint Validation
- Base UI forms use the native constraint validation API.
- Use standard attributes: `required`, `minLength`, `maxLength`, `pattern`, `step`.

## Field and Form
- Set the field name on `Field.Root` and bind inputs with `Field.Control`.
- Use `Form` and `onFormSubmit` for form-level submission and values.
- Use `Fieldset` or `CheckboxGroup` for grouped validation and errors.

## Validation and Errors
- Use `validate`, `validationMode`, and `validationDebounceTime` for custom validation flows.
- Pass `errors` to `Form` for server-side errors and clear them on field change.

## Integrations
- Base UI provides patterns compatible with React Hook Form and TanStack Form.
