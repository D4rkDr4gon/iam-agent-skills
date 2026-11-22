---
name: oneim-customization
description: >
  Use when writing or troubleshooting Designer customization in One Identity Manager (IGA):
  column templates, format scripts, table scripts, Script Library, process/job generation
  conditions, the VB.NET Object Layer API (ScriptBase, dollar notation, IEntity /
  IEntityCollection, UnitOfWork, ObjectWalker), configuration parameters and conditional
  compilation, System Debugger, local vs global compilation. Installation-agnostic.
license: Apache-2.0
---

# oneim-customization

## Purpose

Write, review or debug **Designer customization** in **One Identity Manager**:

- **Templates**: automatic column value calculation (`$...$` notation)
- **Format scripts**: validation/normalization of manually assigned values
- **Table scripts**: logic on before/after save/load/discard events
- **Script Library**: reusable VB.NET functions called from other scripts
- **Process/job generation conditions**: `Value = ...` conditions deciding whether a process or step is generated
- **Configuration parameters**: module activation and conditional compilation (`#If ... #End If`)
- **Scripting API (Object Layer)**: `ScriptBase` (`Base`, `Connection`, `Provider`, `Value`, `Variables`, `Entity`, `Session`), `IEntity` / `IEntityCollection`, `UnitOfWork`, `ObjectWalker`
- **Tools**: Designer (local and global compilation), System Debugger (testing templates and format scripts), Object Browser (last resort, diagnostics only)

**Out of scope**, use the sibling skills:
- General administration (IT Shop, connectors, Job Queue/DBQueue, health checks) → `oneim-manager`
- Safeguard, Active Roles, OneLogin, Password Manager, Starling → their `oneim-*` skills
- Schema extension, system permissions, Web Designer forms → not covered yet; treat as general `oneim-manager` work

> **Generic by design.** No customer data or pre-built customizations. Work from the schema and modules the user describes; never assume custom tables or columns the user has not confirmed.

## Local knowledge base (optional)

Before answering from memory, check whether the user configured a knowledge base:

1. The environment variable `AGENT_KB_DIR` (a folder of notes or docs), or
2. A "Knowledge base" section in `CLAUDE.md` / `AGENTS.md` naming a path or a skill to use for reading it.

If present, search it first (or delegate to the named skill) and cite the note you used. If absent, rely on the official One Identity documentation and say so. Never write to the knowledge base unless the user asks.

---

## What "customizing" means in Identity Manager

Customizing does **not** mean touching product source code. It means extending the **Object Layer** (between the SQL database and clients: Manager, Web Portal, Job Server, Application Server) with declarative pieces that live **in the metadata database** and are compiled to .NET assemblies when the Designer project is compiled.

| Element | Where it is defined | When it runs | Typical goal |
|---|---|---|---|
| **Template** | Designer → table column (*Templates*) | When the column value is calculated during save (always, even if the user did not touch the field) | Derive a value from own columns or FK-related objects |
| **Format script** | Designer → table column (*Format script*) | **Only** when a value is explicitly assigned (manual edit or import) | Validate/normalize input (upper case, trim, regex, `Throw` to reject) |
| **Table script** | Designer → table (before/after save/load/discard) | On object lifecycle events | Cross-column validation, triggering processes after save |
| **Script (Script Library)** | Designer → Script Library | Called explicitly from other scripts | Reuse common logic (helpers, integrations) |
| **Process/job generation condition** | Designer → Process Editor, chain or step condition | When deciding whether to generate a process/step | Control when provisioning fires |

> **Template vs format script**: the template defines *how the value is calculated* (runs on every save); the format script defines *how a written value is validated* (runs only on explicit assignment). They are often combined: the template computes the default, the format script enforces the format if someone overrides it.

### Language and compilation

- The only native language for these extension points is **VB.NET**. **C# is not supported directly**: write it in a custom DLL and reference it from the VB.NET snippet with `References` / `Imports` (wrapped in `#If Not SCRIPTDEBUGGER Then ... #End If`). Native C# only applies to the Web Portal and to sync projects explicitly configured for C#.
- **Configuration parameters**: read them with `Session.Config.GetConfigParm("Path\To\Parameter")` (never query the table directly). They enable `#If PARMNAME Then ... #End If` blocks for conditional compilation depending on which modules are active.
- **Local compilation** (only the snippet being edited, instant feedback) vs **global compilation** (whole project → assemblies used by Manager / Job Server / Application Server). A template that compiles locally can fail globally if it references a table from a disabled module without the matching `#If`; a classic cause of errors when transporting customizations between environments.
- **System Debugger**: test templates and format scripts live before compiling the whole project.

### Dollar notation (`$...$`)

| Notation | Meaning |
|---|---|
| `$Column$` | Base object column value (String by default) |
| `$FK(UID_X).Column$` | Column of an FK-related object (chainable) |
| `$Column:Type$` | Force a type: `:Int`, `:Bool`, `:Date`, `:Double`, `:Long`, `:Decimal` |
| `$Column[D]$` | Display value (resolves limited values / multi-language) |
| `$Column[o]$` | Original value loaded from the database (only valid in the first column reference of the expression) |
| `$[IsLoaded]:Bool$`, `$[IsDeleted]:Bool$`, `$[IsChanged]:Bool$`, `$[IsDifferent]:Bool$`, `$[Display]$` | Object state |
| `DbVal.IsEmpty($Col:Type$, ValType.Type)` | Correct "no value" check (avoids false negatives with dates/strings) |

### `ScriptBase` members available in every script

| Member | Type | Use |
|---|---|---|
| `Value` | `Object` | Templates/format scripts: input and output value |
| `Connection` | `IConnection` | `Connection.BeginTransaction()`, `Connection.GetConfigParm(...)` |
| `Session` | `ISession` | Central access: `Session.Source`, `Session.StartUnitOfWork()`, `Session.Config` |
| `Provider` | `IValueProvider` | Same resolution as `$...$`: `Provider.GetValue("Col").String` |
| `Variables` | `VarContext` | Connection variables, e.g. `Variables("FULLSYNC")` |
| `Entity` / `Base` | `IEntity` / `ISingleDbObject` | Base object (not available in templates/format scripts) |

Methods: `MsgBox(prompt, buttons, title)`, `RaiseMessage(severity, message)` (service log), `ShowProgress(message)`.

### Object Layer: typical CRUD from a script

```vb
' Query + collection
Dim q = Query.From("Person").Where(Function(c) c.Column("FirstName") = "Paula").SelectAll()
Dim col As IEntityCollection = Session.Source.GetCollection(q, EntityCollectionLoadType.Bulk)

' Create
Dim dbPerson As IEntity = Session.Source.CreateNew("Person")
dbPerson.PutValue("FirstName", "Albert")
dbPerson.PutValue("LastName", "Einstein")
Using uow As IUnitOfWork = Session.StartUnitOfWork()
    uow.Put(dbPerson)
    uow.Commit()
End Using

' Delete
Using uow = Session.StartUnitOfWork()
    For Each p As IEntity In col
        p.MarkForDeletion()
        uow.Put(p)
    Next
    uow.Commit()
End Using

' ObjectWalker: read FK values without loading the full object, with caching
Dim val = dbObj.CreateWalker(Session).GetValue("FK(UID_X).FK(UID_Y).Column").String
```

Error handling: `Try / Catch / Finally`, with `Session.RollbackTransaction()` in `Catch` when a transaction is open, and `Throw` (rethrow) or `Throw New Exception("message", ex)` to add context.

---

## Reference sources (priority order)

1. **Official SDK script samples**: shipped with the One Identity Manager installation media (SDK / script samples folder): common ScriptBase usage, database connections, database objects (CRUD, ObjectWalker, UnitOfWork), templates, process chains, files, expert topics (LDAP, Registry, AD), COM, PowerShell, web services. Executable vendor code; the most reliable source for exact syntax. Ask the user whether they have it available (it may also be in their knowledge base).
2. **The user's knowledge base**, if configured (see above).
3. **Official documentation**: the *Configuration Guide* for your version (chapter *Scripts in One Identity Manager*) on `support.oneidentity.com` / `docs.oneidentity.com`, and the One Identity Community forums.
4. **Web fallback**: search the exact error message or API signature.

---

## Working protocol

### 1. Get context (if not already in the conversation)

- Product version?
- Which table/column? Standard table or custom schema extension?
- Template, format script, table script or a Script Library method?
- Specific configuration parameters/modules involved (to know whether `#If` is needed)?
- New development or troubleshooting something that already fails?

### 2. Check sources before writing new code

Look for an equivalent example in the SDK samples or the knowledge base first; adapting a proven pattern is safer than writing from scratch.

### 3. Answer

- Deliver the complete VB.NET snippet and say **where to paste it** in Designer (column → Templates / Format script; table → Table scripts; Script Library → function name) and which **configuration parameters** or `#If` blocks it needs.
- If the request involves IT Shop, connectors or general administration → hand over to `oneim-manager`.
- If unsure about an exact API signature or behaviour, say so and verify against the SDK or official docs before asserting it.

### 4. Document (only if the user asks)

Append to the knowledge base following its structure; do not delete or reorder existing content unless asked.

---

## Troubleshooting

| Symptom | Likely cause | Action |
|---|---|---|
| Template/format script fails in global compilation but works locally | References a table/column of a disabled module without `#If` | Wrap the block in the matching `#If PARMNAME` |
| Format script never fires | Expected it to run on every save (that is a template) | Use a template to always recalculate; a format script is right only for validating explicit edits |
| `$Column[o]$` compile error | `[o]` used outside the first column reference (e.g. `$FK(Col).Other[o]$`) | Only valid as `$Column[o]$` or `$FK(Column[o]).Other$` |
| End user never sees the error in Manager/Web Portal | Used `RaiseMessage`/logging instead of `Throw` in a format script | To block the save and show a message, use `Throw New Exception("message")` |
| External assembly reference breaks System Debugger | Missing `#If Not SCRIPTDEBUGGER Then` around `References` / `Imports` | Always wrap `References` / `Imports` in that block |

---

## References

- *Configuration Guide* (your version): `https://support.oneidentity.com/technical-documents/identity-manager/`
- GitHub: `https://github.com/OneIdentity`
- Community: `https://www.oneidentity.com/community/identity-manager/`
