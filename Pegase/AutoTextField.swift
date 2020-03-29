import AppKit

final class AutoTextField: NSTextField, NSTextFieldDelegate {
    
    @IBInspectable public var fillCompletions: Bool = false

    private var suggestionsController: SuggestionsWindowController?
    private var skipNextSuggestion = false
    
    // Do not take the focus if set to true
    public var refuseFocus: Bool = false

    // If set to true, select all the text when we get a mouseDown event
    private var wantsSelectAll = false

    let suggestions = [[String: String]]()
    var arrNames = [["label": "abc"], ["label": "cde"], ["label": "fgh"], ["label": "aab"]]
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }
    
    private func setup() {
        self.delegate = self
    }
    
    override public func becomeFirstResponder() -> Bool {
        if refuseFocus {
            return false
        }
        // Select all the text when we get the focus
        wantsSelectAll = true
        return super.becomeFirstResponder()
    }
    
    
    func updateSuggestions(from control: NSControl?) {

        let fieldEditor: NSText? = window?.fieldEditor(false, for: control)
        if fieldEditor != nil {
            // Only use the text up to the caret position
            let selection: NSRange? = fieldEditor?.selectedRange
            let text = (selection != nil) ? (fieldEditor?.string as NSString?)?.substring(to: selection!.location) : nil
            
            let suggestions = self.suggestions(forText: text!)
            
            if suggestions.isEmpty == false {
                let suggestion = suggestions[0]
                updateFieldEditor(fieldEditor, withSuggestion: suggestion[kSuggestionLabel])
                suggestionsController?.setSuggestions(suggestions)
                if !(suggestionsController?.window?.isVisible ?? false) {
                    suggestionsController?.begin(for: (control as? NSTextField))
                }
            } else {
                suggestionsController?.cancelSuggestions()
            }
        }
    }
    
    private func updateFieldEditor(_ fieldEditor: NSText?, withSuggestion suggestion: String?) {
        let selection = NSRange(location: fieldEditor?.selectedRange.location ?? 0, length: suggestion?.count ?? 0)
        fieldEditor?.string = suggestion ?? ""
        fieldEditor?.selectedRange = selection
    }
    
    func suggestions(forText text: String) -> [[String: String]] {
        let namePredicate = NSPredicate(format: "label BEGINSWITH[cd] %@",text)
        let suggestions = arrNames.filter { namePredicate.evaluate(with: $0) }
        return suggestions
    }
    
    @IBAction public func update(withSelectedSuggestion sender: Any?) {
        let entry = (sender as? SuggestionsWindowController)?.selectedSuggestion()
        if entry != nil && !entry!.isEmpty {
            let fieldEditor: NSText? = self.window?.fieldEditor(false, for: self)
            if fieldEditor != nil {
                updateFieldEditor(fieldEditor, withSuggestion: entry![kSuggestionLabel])
            }
        }
    }
    
    func controlTextDidBeginEditing(_ notification: Notification) {
        if !skipNextSuggestion {
            // We keep the suggestionsController around, but lazely allocate it the first time it is needed.
            if suggestionsController == nil {
                suggestionsController = SuggestionsWindowController()
                suggestionsController?.target = self
                suggestionsController?.action = #selector(AutoTextField.update(withSelectedSuggestion:))
            }
            updateSuggestions(from: notification.object as? NSControl)
        }
    }
    
    func controlTextDidChange(_ notification: Notification) {
        if !skipNextSuggestion {
            updateSuggestions(from: notification.object as? NSControl)
        } else {
            suggestionsController?.cancelSuggestions()
            skipNextSuggestion = false
        }
    }
    
    // If the suggestionController is already in a cancelled state,
    //this call does nothing and is therefore always safe to call.
    func controlTextDidEndEditing( _ obj: Notification) {
        suggestionsController?.cancelSuggestions()
    }
    
    /* As the delegate for the NSTextField, this class is given a chance to respond to the key binding commands interpreted by the input manager when the field editor calls -interpretKeyEvents:. This is where we forward some of the keyboard commands to the suggestion window to facilitate keyboard navigation. Also, this is where we can determine when the user deletes and where we can prevent AppKit's auto completion.
     */
    public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.moveUp(_:)) {
            // Move up in the suggested selections list
            suggestionsController?.moveUp(textView)
            return true
        }
        if commandSelector == #selector(NSResponder.moveDown(_:)) {
            // Move down in the suggested selections list
            suggestionsController?.moveDown(textView)
            return true
        }
        if commandSelector == #selector(NSResponder.deleteForward(_:)) || commandSelector == #selector(NSResponder.deleteBackward(_:)) {
            if fillCompletions {
                // Disabled by default as modern search fields do not do this.
                let insertionRange = textView.selectedRanges[0].rangeValue
                if commandSelector == #selector(NSResponder.deleteBackward(_:)) {
                    skipNextSuggestion = (insertionRange.location != 0 || insertionRange.length > 0)
                } else {
                    skipNextSuggestion = (insertionRange.location != textView.string.count || insertionRange.length > 0)
                }
            }
            return false
            
        }
        if commandSelector == #selector(NSResponder.complete(_:)) {
            // The user has pressed the key combination for auto completion. AppKit has a built in auto completion. By overriding this command we prevent AppKit's auto completion and can respond to the user's intention by showing or cancelling our custom suggestions window.
            if suggestionsController != nil && suggestionsController!.window != nil && suggestionsController!.window!.isVisible {
                suggestionsController?.cancelSuggestions()
            } else {
                updateSuggestions(from: control)
            }
            return true
        }
        return false
    }

}
