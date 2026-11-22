# Form Builder components (Identity Manager 4.10 / CE 24.4)

Source: the official *Administrator's Guide to Form Builder*. For generic Form.io properties (Display, Data, Validation, API, Conditional, Logic), see the Form.io component settings docs. Availability can vary by version. Check the guide that matches the user's version.

## Official component list

| Group | Components |
|---|---|
| **Basic** | Text Field, Number, Text Area, Checkbox, Select Boxes, Time, Select, Radio, Content, Button |
| **Advanced** | Email, Url, Data Item Mapping, Phone Number, Date/Time, Day, Tags, Currency, HTML Element, Signature, Survey, Dynamic Entity, DN Query, Title Element, Tree Element, DN Display, Permission Request DN, Label Element |
| **Layout** | Columns, Field Set, Panel, Table, Tabs, Well |
| **Data** | Hidden, Container, Data Grid, Data Map, Edit Grid |

## Identity Manager-specific components (Data tab)

### Dynamic Entity
Picks values from an Identity Vault entity.
Fields: **Entity Key**, **Display Expression Attribute**, **Service ID**, **Limit** (default 20), **Default Value**, **Refresh On**.

### DN Query
Runs a predefined query.
Fields: **Service ID**, **Parameters**, **Query Key**, **Return Attributes**, **Default Value**, **Refresh On**.
Parameters do not accept dynamic values such as `data.<field>`. For dynamic queries, use `IDVault.globalquery` in a **Select** component.

### Tree Element
Shows a hierarchy, such as containers.
**Data Source Type**: JSON or URL. Node keys: `dn`, `name`, `data`, `subcontainers`, `icon`.
URL source fields: **HTTP method**, **Service ID**, **Data Source URL**, **Mapper keys for URL response**, **Request Headers**, **Request payload**, **lazy parameter**.

### Others
- **DN Display**: shows a DN in readable form.
- **Permission Request DN**: replaces legacy `nrfRequestDN`.
- **Title Element** and **Label Element**: display-only. For mapping on a Title Element, leave **Title Content** blank.
- **Data Item Mapping**: component for mapping-related data.

## Legacy widget → JSON component (official mapping)

| Legacy widget | JSON form component |
|---|---|
| Static list | Select |
| Global list | Select with the Global List API (`IDVault.globalList`) |
| Pick list | Dynamic Entity / Select / multivalued Select |
| checkboxPicklist, mvCheckbox | Select Boxes |
| Radio buttons | Radio |
| DN Maker | Tree with Text Field |
| DNquery | DN Query, or Select with the Global Query API |
| nrfRequestDN | Permission Request DN |
| Date | Day |

## Common Form.io patterns

These use only standard Form.io properties. Get the exact JSON from **Form JSON** in your own Designer before editing it.

**Static select (single or multiple)**

```json
{ "type": "select", "key": "<propertyName>", "label": "<Label>", "input": true,
  "dataSrc": "values",
  "data": { "values": [ { "label": "Option A", "value": "a" }, { "label": "Option B", "value": "b" } ] },
  "multiple": false, "validate": { "required": true } }
```

For multiple selection, set `"multiple": true`. The value is then an array, so check the flowdata mapping.

**Dependent field (cascading)**: set **Refresh On** (`refreshOn`) on the child to the parent's Property Name. Optionally set `clearOnRefresh`. The child's data or default value logic reads `data.<parentKey>`.

**Calculated, read-only field**: set Display → **Disabled**, then set **Calculated Value** to `value = ...;`.

**Conditionally visible field**: on the Conditional tab, use a Simple condition, or JavaScript `show = ...;`.

**Repeatable rows**: use **Data Grid** with child components. The submission value is an array of row objects.
