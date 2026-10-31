# Dev Assist

A simple multi-clipboard application for developers.

## Usage

- **Add an entry** by clicking **Add** or pressing <kbd>Cmd</kbd>+<kbd>V</kbd>. Adds whatever text is on the clipboard at the moment.
- **Double-click an entry** to copy it to the clipboard.
- **Entries are remembered** after closing the app.

### Properties

Right-click an entry and choose **Properties…** to:

- **Lock** it, so it cannot be deleted and will stay if you clear the list.
- **Mask** it, so the actual text is not displayed in the app but is still copied on double-click.

## Security

Saved data is encrypted. The encryption key is stored in your Keychain, so macOS will ask for access the first time.

> [!TIP]
> Click **Always Allow** so it won't ask again.
