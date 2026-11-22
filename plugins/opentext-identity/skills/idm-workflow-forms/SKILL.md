---
name: idm-workflow-forms
description: >
  Use when building or troubleshooting OpenText (NetIQ) Identity Manager JSON workflow
  forms with the Designer Form Builder (based on Form.io): request, approval and template
  forms; components (Select, Dynamic Entity, DN Query, Tree, Data Grid, …); component
  settings (Data, Custom Default Value, Calculated Value, Validation, API, Conditional,
  Logic); the JS Editor, IDVault macros and REST calls; buttons; localization; data item
  mapping; migration from legacy forms. Linux and Windows.
license: Apache-2.0
---

# idm-workflow-forms

## Purpose

Design, configure and troubleshoot **JSON workflow forms** for OpenText Identity Manager, built with the **Form Builder** in Designer. This skill is based only on the official *Administrator's Guide to Form Builder* and the Form.io documentation. If something is not covered there, say so. Do not invent component properties or APIs.

**Out of scope**: drivers (`idm-identity-drivers`), servers (`idm-identity-servers`), certificates (`enterprise-certificates`), Access Manager (`nam-access-manager`).

> **Generic by design.** Never assume that an entity key, global list, service ID or property name exists in the user's environment. Ask, or tell the user what to confirm.

## Local knowledge base (optional)

Before answering from memory, check whether the user configured a knowledge base:

1. The environment variable `AGENT_KB_DIR` (a folder of notes or docs), or
2. A "Knowledge base" section in `CLAUDE.md` / `AGENTS.md` naming a path or a skill to use for reading it.

If one exists, search it first (or delegate to the named skill) and cite the note you used. It may hold the user's own form conventions or helper libraries. Use those only when the user works in that environment. If there is no knowledge base, rely on the official documentation and say so. Never write to the knowledge base unless the user asks.

---

## Form Builder essentials (official guide)

- Forms are stored as **JSON**, and OpenText recommends the Form Builder over legacy forms. The Form Builder is a Form.io builder: each component dragged onto the form adds its JSON schema.
- The **Form Renderer** in Identity Applications renders Form Builder forms. Legacy forms still render with Dojo.
- **Form types**: Approval Forms, Request Forms and Template Forms, under **Workflow Forms** in Designer's Outline view.

### Creating and associating a form

1. In Designer, go to the Provisioning view and right-click **Provisioning Request Definitions** → New.
2. On the PRD **Overview** tab, select **JSON Forms Selection**.
3. Create the form in one of two ways:
   - In the Outline view, open **Workflow Forms** and right-click **Approval Forms**, **Request Forms** or **Template Forms**.
   - In the Form Builder, use **+ New Form** or **Form Templates**. Form Templates replaced *New Form* in 4.8.1.
4. Associate the form on the PRD **JSON Forms** tab (Form ID list).
5. Map data on the **Workflow** tab (Data Item Mapping).
6. Deploy to the Identity Vault from Designer.

### Toolbar

- **Form Templates**
- **Form Builder**
- **JS Editor**
- **Form JSON**: edit the schema directly.
- **Preview**: association with the PRD does not work in preview.
- **Localization**
- **External Scripts**: add a JavaScript URL.
- **Save**: saves the form as XML in the project.
- **Settings**: language, preview settings and Debug Mode.
- **Offline/Online** toggle. Online mode needs `FormsBackedUrl` in Designer's `ServiceRegistry.json`, pointing to `https://<identity-apps-host>:8600/WFHandler`.

### Components

`references/components.md` has:
- the full official list (Basic, Advanced, Layout, Data);
- the IDM-specific components and their Data tab fields;
- the mapping from legacy widgets to JSON components.

### Component settings tabs

**Display**, **Data**, **Custom Default Value**, **Calculated Value**, **Validation**, **API**, **Conditional**, **Logic** and **Layout** (4.8.1+).

- **API → Property Name** must be **unique** in the form. It is the key in the submission data and the name that data item mapping, conditions and scripts use.
- When both are set, **Custom Default Value overrides the Data Item Mapping value**.
- The Form Builder supports only the **OnLoad** and **OnChange** field events directly.

### Form.io evaluation rules (custom JavaScript in settings)

Available variables include `data`, `row`, `input`, `component`, `instance`, `form`, `submission`, `utils`, `moment` and `_`.

Assign to the expected variable instead of using `return`:

| Setting | Variable to assign |
|---|---|
| Custom Default Value, Calculated Value | `value` |
| Custom Validation | `valid` (`true` or an error string) |
| Advanced (JavaScript) Conditional | `show` |
| Logic → JavaScript trigger | `result` |

```javascript
value = data.firstName + ' ' + data.lastName;                // Calculated Value
valid = (input === data.email) ? true : 'Emails must match';  // Custom Validation
show  = data.requestType === 'temporary';                     // Conditional
```

Prefer **Simple** conditionals over JavaScript, because JavaScript conditions add overhead. Simple conditionals live on the Conditional tab: Is Equal To, Is Empty, Greater Than and so on, with When = One/All.

### Logic tab

**+Add Logic** creates a logic instance with a trigger and actions.
- Triggers: **Simple**, **Javascript**, **JSON Logic** and **Event** (your own custom events).
- Actions: **Property** (Required, Label, Disabled, …), **Value**, **Merge Component Schema** and **Custom Action**.

### Buttons

The official guide implements Submit, Cancel, Approve and Deny with logic: you define the API call in the button's **Button Custom Logic** field on the **Display** tab. When several components must react, use custom events plus Event-triggered logic.

---

## JS Editor, IDVault macros and REST

- The **JS Editor** is the global place to add or modify JavaScript methods for all fields.
- It auto-creates methods for **Custom Default Value** and **Calculated Value**, named after the property: `<key>_CustomDefaultValue` and `<key>_CalculateValue`. The default variable is `value`.
- For async results, set values with `instance.setFieldValue(response, valueProperty, labelProperty, defaultValueToSet)`. This works for Radio, Select Boxes and Select. Pass `component.defaultValue` as the fourth argument so that data item mapping can still set the default.
- To read or set other fields, use `instance.root.getComponent('<key>').setValue(...)`.
- The **REST API** icon in the JS Editor lists GET/POST helpers for the REST servers defined in the forms **ServiceRegistry**.
- **Identity Manager macros** (`IDVault.*`) call Identity Apps REST APIs internally:

```javascript
// Read user attributes
IDVault.get('IDM', '/rest/access/entities/list', '<user-dn>', 'user', ['TelephoneNumber', 'LastName'])
// Read a global list
IDVault.globalList('IDM', '/rest/access/entities/globalList', '<list-name>', 'en')
```

When a query needs dynamic parameters, use `IDVault.globalquery` in a Select. The DN Query component does not accept `data.<field>` values as parameters.

Check the guide for your exact version before relying on any other macro.

---

## Data item mapping

- Pre-activity mapping fills the form. Post-activity mapping writes submitted values back to flowdata. Configure both on the PRD **Workflow** tab.
- Mapping uses the component **Property Name**. If you rename a property, redo the mapping.
- A Custom Default Value takes precedence over the mapped value.

## Migration from legacy forms

There is **no migration tool**:
1. Back up the PRD.
2. Build the new JSON form. Use the legacy-to-JSON mapping in `references/components.md`.
3. On the Overview tab, select **JSON Forms Selection**. **Warning:** Designer then deletes all legacy forms associated with the PRD **and their data item mapping fields**.
4. Associate the form on the JSON Forms tab.
5. Redo data item mapping on the Workflow tab.
6. Deploy and test.

---

## Working protocol

1. **Context**: IDM version, form type, new or existing form, associated PRD and the symptom (data not mapped, wrong values, button does nothing, …).
2. **Sources**: the knowledge base if configured, then the official Form Builder guide for that version, then the Form.io docs.
3. **Answer** with component JSON (from **Form JSON**) or JS Editor code. Say which tab or setting it goes in. List what the user must confirm: service ID, entity key, global list name and property names.
4. **Validate** before handing it over: the JSON parses, Property Names are unique, mapping names match, and each button's logic or event is wired.
5. **Document** only if the user asks.

## Known issues (from the official guide)

| Issue | Workaround |
|---|---|
| Fields show wrong values when the provided value is null/undefined | Check for `undefined`/`null` before setting |
| A form that uses `alert()` cannot be edited | Use `window.alert()` |
| Data item mapping does not work for a Title Element | Leave **Title Content** blank |
| A Select does not show all search results | Add `"searchResultLimit": <n>` to the Select's custom default options |
| The *Multiple Values* checkbox does not work for Number, Currency, Phone Number or Tags | Put the component inside a Data Grid |
| A form with a Tabs layout does not open in the Dashboard | Add `"components": []` to the tabs |

Debugging tools: Form Builder **Debug Mode**, **Preview**, the browser console (F12) in Identity Applications, and the workflow log on the Identity Applications server (see `idm-identity-servers`).

---

## References

- [Administrator's Guide to Form Builder, Identity Manager 4.10 / CE 24.4](https://www.netiq.com/documentation/identity-manager-4.10/form_builder/data/form_builder.html)
- [Designing Identity Applications: forms and PRDs](https://www.netiq.com/documentation/identity-manager-4.10/identity_apps_design/data/about-prd-forms.html)
- [Form.io: Form Builder](https://help.form.io/developers/form-development/form-builder)
- [Form.io: Component settings](https://help.form.io/form-building/component-settings)
- [Form.io: Logic and conditions](https://help.form.io/userguide/form-building/logic-and-conditions)
