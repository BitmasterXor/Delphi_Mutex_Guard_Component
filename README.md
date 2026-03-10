# MutexGuard - Delphi VCL Single-Instance Component

<p align="center">
  Professional drag-and-drop Delphi VCL component for enforcing one running instance per custom mutex name.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Delphi-VCL%20Win32-E62431?style=for-the-badge" alt="Delphi VCL Win32">
  <img src="https://img.shields.io/badge/Delphi-VCL%20Win64-8E44AD?style=for-the-badge" alt="Delphi VCL Win64">
  <img src="https://img.shields.io/badge/Platform-Windows-0078D6?style=for-the-badge" alt="Windows">
  <img src="https://img.shields.io/badge/Component-TSingleInstanceGuard-2D3436?style=for-the-badge" alt="TSingleInstanceGuard">
</p>


## Overview
<p align="center">
  <img src="Preview.png" alt="Preview" width="700">
</p>
`TSingleInstanceGuard` wraps the Windows named mutex workflow into a reusable non-visual component.

Instead of writing startup mutex boilerplate in every project, you can drop one component on your main form or data module and configure behavior from the Object Inspector.

## What This Solves

- Prevents duplicate instances of your app from running with the same mutex identity.
- Supports custom mutex names for project-specific or customer-specific app channels.
- Provides controlled behavior for second-instance detection.
- Keeps implementation clean, consistent, and easy to reuse across Delphi projects.

## Repository Contents

- `MutexGuard.dpk` / `MutexGuard.dproj`: design-time package project
- `uSingleInstanceGuard.pas`: component source code
- `uSingleInstanceGuard.dcr` + `TSingleInstanceGuard.bmp`: palette icon resources
- `Demo/SingleInstanceDemo.dpr` / `Demo/SingleInstanceDemo.dproj`: demo project
- `Demo/DemoMainForm.pas` / `DemoMainForm.dfm`: demo UI and event wiring

## Install In RAD Studio

1. Open `MutexGuard.dproj` (or `MutexGuard.dpk`).
2. Build the package.
3. Install the generated `MutexGuard.bpl` from `Component > Install Packages...`.
4. Locate `TSingleInstanceGuard` on the `Utilities` component tab.

## Quick Usage

1. Drop `TSingleInstanceGuard` on your main form.
2. Set `MutexName` to the identity you want enforced.
3. Keep `Active = True`.
4. Set `DuplicateAction = daTerminate` to automatically close second instances.

### Example

```pascal
procedure TMainForm.FormCreate(Sender: TObject);
begin
  SingleInstanceGuard1.MutexName := 'MyCompany.MyProduct.SingleInstance';
  SingleInstanceGuard1.DuplicateAction := daTerminate;
  SingleInstanceGuard1.Active := True;
end;

procedure TMainForm.SingleInstanceGuard1SecondInstance(
  Sender: TObject; const MutexName: string);
begin
  MessageDlg('Another instance is already running:' + sLineBreak + MutexName,
             mtWarning, [mbOK], 0);
end;
```

## API Reference

### Properties

- `Active`: Enables or disables guard enforcement.
- `MutexName`: Custom mutex identifier. If no namespace prefix is provided, one is applied automatically.
- `UseGlobalNamespace`: Chooses default namespace when no prefix is supplied.
- `DuplicateAction`: Action to take on duplicate detection (`daTerminate` or `daNone`).

### Read-Only Runtime State

- `EffectiveMutexName`: Final normalized mutex name used internally.
- `IsPrimaryInstance`: Indicates whether this process owns the mutex.
- `LastErrorCode`: Last WinAPI result from mutex creation.

### Event

- `OnSecondInstance(Sender, MutexName)`: Fired when another instance already owns the mutex.

### Methods

- `StartGuard`
- `StopGuard`

## Namespace Behavior

- `UseGlobalNamespace = False`: Uses `Local\` namespace (per user logon session).
- `UseGlobalNamespace = True`: Uses `Global\` namespace (machine-wide across sessions).
- If `MutexName` already starts with `Local\` or `Global\`, that explicit prefix is used as-is.

## Demo Project

Run `Demo/SingleInstanceDemo.dpr` to test:

- Changing mutex names at runtime
- Restarting guard behavior
- Duplicate-instance warning and termination flow
- Runtime event/status logging

## Build Configurations

Both package and demo projects include:

- `Debug`
- `Release`

## License

This project is provided as-is without warranty.

## Contact

Discord: `BitmasterXor`

<p align="center">Built by BitmasterXor using Delphi RAD Studio</p>
