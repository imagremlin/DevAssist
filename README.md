# Dev Assist

A multi-clipboard and log helper for developers on macOS.

## Clips

- **Add an entry** by clicking **+** or pressing <kbd>Cmd</kbd>+<kbd>V</kbd>. Adds whatever text is on the clipboard at the moment.
- **Add with a title** by <kbd>Option</kbd>-clicking **+**. Opens the clip's properties before adding it; **Cancel** adds nothing.
- **Double-click an entry** to copy it to the clipboard.
- **Search** with the box at the top of the list. Matches titles and text (sensitive clips match by title only).
- **Remove** the selected entry with **−** or the <kbd>Delete</kbd> key. **Clear** (trash icon) removes all unlocked entries.
- **Entries are remembered** after closing the app.

### Properties

Right-click an entry and choose **Get information…** (or select it and click **i**) to set:

- **Title**: shown in the list instead of the text (in italics). Hover over the entry to see the full text.
- **Locked**: the entry cannot be removed, survives **Clear**, and is listed at the top.
- **Sensitive**: for passwords and similar values.
  - The text is never displayed: the title is shown instead, or `••••••` if there is none.
  - Search only matches the title, never the hidden text.
  - When copied, the clipboard entry is marked as concealed, so clipboard managers that honour the convention skip it.
  - The clipboard is cleared after 30 seconds, unless something else has been copied in the meantime.
- **Autotype Always**: selecting the entry from the menu bar always types it, even when autotype mode is off. See [Autotype](#autotype).

The right-click menu also offers **Copy**, **Update** (replace the entry's text with the clipboard), **Lock/Unlock**, **Make Sensitive** and **Remove**.

## Menu bar

The clipboard icon in the menu bar gives quick access without opening the window:

- The **10 most recently used** entries. Select one to copy it (or type it, see [Autotype](#autotype)).
- **Add from Clipboard**. Hold <kbd>Option</kbd> to get **Add with Title…** instead.
- **Clear Unlocked**, **Log Processor…**, the **Autotype** toggle, **Open Dev Assist** and **Quit**.

## Autotype

Instead of copying an entry to the clipboard, Dev Assist can **type** it into whatever app and field has the keyboard focus. This works from the menu bar only: opening the menu leaves focus where your cursor was, so the text goes there.

- Turn on **Autotype** in the menu bar menu (or **Tools → Autotype**). Selecting an entry from the menu bar then types it.
- Mark an entry **Autotype Always** in its properties to type it even when autotype mode is off.
- Hold <kbd>Option</kbd> while the menu is open to **copy** an entry instead of typing it. The entry's label changes to show it will be copied.
- Line breaks are typed as <kbd>Return</kbd> and tabs as <kbd>Tab</kbd>, so a single entry such as `username⇥password↵` fills in a login form and submits it.
- Typed text never touches the clipboard, which makes autotype a good fit for sensitive entries.

> [!IMPORTANT]
> Autotype needs **Accessibility** permission: **System Settings → Privacy & Security → Accessibility**, then enable **Dev Assist**. Without it, nothing is typed. The permission is tied to the app's signature, so ad hoc builds may need re-approving after a rebuild (see [Building](#building)).

> [!CAUTION]
> Text is typed wherever the focus is. Check where your cursor is before typing a password, so it doesn't end up in a chat window or document.

## Log Processor

Extracts your own debug output from a noisy log, such as Visual Studio's Output window, where your `Debug.WriteLine` messages are mixed with binding errors, assembly loads and stack traces.

1. Prefix your debug messages with something distinctive, e.g. `TW-1234`.
2. Copy the whole log.
3. Open **Tools → Log Processor…** (or **Log Processor…** in the menu bar), enter the prefix and click **Process**.
4. The cleaned log, containing only your messages, replaces the clipboard contents.

Details:

- Everything **before** the prefix on a line is discarded, so messages appended to other output by a stray `Debug.Write` (no newline) are still found.
- Several messages on one line are split onto separate lines.
- Trailing whitespace is trimmed, and Windows (`\r\n`) line endings are handled.
- The prefix is remembered for next time.

> [!TIP]
> Choose a prefix that won't appear inside your messages, e.g. `TW-1234:` or `##`, since text is split at every occurrence of the prefix.

## Remove Formatting
Removes all formatting from text in the clipboard.

> [!TIP]
> Ensure the application you're pasting into doesn't have hidden formatting markers 

## Security

Saved data is encrypted and stored in `~/Library/Application Support/DevAssist/clips.json`. The encryption key is stored in your Keychain, so macOS will ask for access the first time.

Dev Assist is not sandboxed, because autotype requires sending keyboard input to other apps.

> [!TIP]
> Click **Always Allow** so it won't ask again.

## Building

Open `DevAssist.xcodeproj` in Xcode and run.

Signing is configured in `Base.xcconfig`. By default the app is signed to run locally (ad hoc), which works on any Mac but means the Keychain prompt reappears after each rebuild, and the Accessibility permission for autotype may need re-approving. To avoid that, create a self-signed code signing certificate (**Keychain Access → Certificate Assistant → Create a Certificate…**, type **Code Signing**) and a `Local.xcconfig` next to `Base.xcconfig`:

```
CODE_SIGN_IDENTITY = <your certificate name>
```

`Local.xcconfig` is git-ignored, so each Mac can use its own certificate without changing the project.

## Tests

Run the tests with <kbd>Cmd</kbd>+<kbd>U</kbd>. While tests run, the app uses an in-memory store, so your saved clips and Keychain are never touched.
