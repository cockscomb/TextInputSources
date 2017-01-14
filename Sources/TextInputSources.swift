import Carbon

public extension Notification.Name {
    public static let selectedKeyboardInputSourceChanged = Notification.Name(rawValue: kTISNotifySelectedKeyboardInputSourceChanged as String)
    public static let enabledKeyboardInputSourceChanged = Notification.Name(rawValue: kTISNotifyEnabledKeyboardInputSourcesChanged as String)
}

public enum TextInputSourcesError: Error {
    case cannotSelect
    case cannotDeselect
    case cannotEnable
    case cannotDisable
    case cannotRegister
    case cannotOverrideKeyboardLayout
    case unknown(OSStatus)
}

public struct TextInputSources {
    private init() {}

    public static func find(filtering properties: [FilteringPropertyName: Any] = [:], includeAllInstalled: Bool = false) -> [InputSource] {
        var transformed: [AnyHashable: Any] = [:]
        for (key, value) in properties {
            if let value = (value as? FilteringPropertyValue)?.internalValue {
                transformed[key.rawValue as String] = value
            } else {
                transformed[key.rawValue as String] = value
            }
        }
        let inputSourceList = TISCreateInputSourceList(transformed.isEmpty ? nil : (transformed as CFDictionary), includeAllInstalled)!
        return (takeValue(fromCreated: inputSourceList) as! [TISInputSource]).map(InputSource.init)
    }

    public static var current: InputSource {
        return InputSource(takeValue(fromCopied: TISCopyCurrentKeyboardInputSource()))
    }

    public static var currentLayout: InputSource {
        return InputSource(takeValue(fromCopied: TISCopyCurrentKeyboardLayoutInputSource()))
    }

    public static var currentASCIICapable: InputSource {
        return InputSource(takeValue(fromCopied: TISCopyCurrentASCIICapableKeyboardInputSource()))
    }

    public static var currentASCIICapableLayout: InputSource {
        return InputSource(takeValue(fromCopied: TISCopyCurrentASCIICapableKeyboardLayoutInputSource()))
    }

    public static func inputSource(forLanguage language: String) -> InputSource? {
        guard let source = TISCopyInputSourceForLanguage(language as CFString) else {
            return nil
        }
        return InputSource(takeValue(fromCopied: source))
    }

    public static var asciiCapableInputSources: [InputSource] {
        return (takeValue(fromCreated: TISCreateASCIICapableInputSourceList()) as! [TISInputSource]).map(InputSource.init)
    }

    // MARK: - Select/Deselect/Enable/Disable

    public static func select(_ inputSource: InputSource) throws {
        let status = TISSelectInputSource(inputSource.tisInputSource)
        switch status {
        case noErr:
            return
        case Int32(paramErr):
            throw TextInputSourcesError.cannotSelect
        default:
            throw TextInputSourcesError.unknown(status)
        }
    }

    public static func deselect(_ inputSource: InputSource) throws {
        let status = TISDeselectInputSource(inputSource.tisInputSource)
        switch status {
        case noErr:
            return
        case Int32(paramErr):
            throw TextInputSourcesError.cannotDeselect
        default:
            throw TextInputSourcesError.unknown(status)
        }
    }

    public static func enable(_ inputSource: InputSource) throws {
        let status = TISEnableInputSource(inputSource.tisInputSource)
        switch status {
        case noErr:
            return
        case Int32(paramErr):
            throw TextInputSourcesError.cannotEnable
        default:
            throw TextInputSourcesError.unknown(status)
        }
    }

    public static func disable(_ inputSource: InputSource) throws {
        let status = TISDisableInputSource(inputSource.tisInputSource)
        switch status {
        case noErr:
            return
        case Int32(paramErr):
            throw TextInputSourcesError.cannotDisable
        default:
            throw TextInputSourcesError.unknown(status)
        }
    }

    // MARK: - Register

    public static func registerInputSource(at url: URL) throws {
        let status = TISRegisterInputSource(url as CFURL)
        switch status {
        case noErr:
            return
        case Int32(paramErr):
            throw TextInputSourcesError.cannotRegister
        default:
            throw TextInputSourcesError.unknown(status)
        }
    }

    // MARK: - Override keyboard layout

    public static func setOverrideKeyboardLayout(with keyboardLayout: InputSource?) throws {
        let status = TISSetInputMethodKeyboardLayoutOverride(keyboardLayout?.tisInputSource)
        switch status {
        case noErr:
            return
        case Int32(paramErr):
            throw TextInputSourcesError.cannotOverrideKeyboardLayout
        default:
            throw TextInputSourcesError.unknown(status)
        }
    }

    public static func overrideKeyboardLayout() -> InputSource? {
        guard let keyboardLayout = TISCopyInputMethodKeyboardLayoutOverride() else {
            return nil
        }
        return InputSource(takeValue(fromCopied: keyboardLayout))
    }
}

extension TextInputSources {
    public enum FilteringPropertyName: RawRepresentable {
        case category
        case kind
        case asciiCapablility
        case enableCapability
        case selectCapability
        case enabled
        case selected
        case id
        case bundleID
        case inputModeID
        case localizedName

        public init?(rawValue: CFString) {
            switch rawValue as String {
            case String(kTISPropertyInputSourceCategory):
                self = .category
                case String(kTISPropertyInputSourceType):
                self = .kind
            case String(kTISPropertyInputSourceIsASCIICapable):
                self = .asciiCapablility
                case String(kTISPropertyInputSourceIsEnableCapable):
                self = .enableCapability
            case String(kTISPropertyInputSourceIsSelectCapable):
                self = .selectCapability
                case String(kTISPropertyInputSourceIsEnabled):
                self = .enabled
            case String(kTISPropertyInputSourceIsSelected):
                self = .selected
                case String(kTISPropertyInputSourceID):
                self = .id
            case String(kTISPropertyBundleID):
                self = .bundleID
                case String(kTISPropertyInputModeID):
                self = .inputModeID
            case String(kTISPropertyLocalizedName):
                self = .localizedName
            default:
                return nil
            }
        }

        public var rawValue: CFString {
            switch self {
            case .category:
                return kTISPropertyInputSourceCategory
            case .kind:
                return kTISPropertyInputSourceType
            case .asciiCapablility:
                return kTISPropertyInputSourceIsASCIICapable
            case .enableCapability:
                return kTISPropertyInputSourceIsEnableCapable
            case .selectCapability:
                return kTISPropertyInputSourceIsSelectCapable
            case .enabled:
                return kTISPropertyInputSourceIsEnabled
            case .selected:
                return kTISPropertyInputSourceIsSelected
            case .id:
                return kTISPropertyInputSourceID
            case .bundleID:
                return kTISPropertyBundleID
            case .inputModeID:
                return kTISPropertyInputModeID
            case .localizedName:
                return kTISPropertyLocalizedName
            }
        }
    }
}

private func takeValue<Instance>(fromCreated created: Unmanaged<Instance>) -> Instance {
    defer {
        created.release()
    }
    return created.takeUnretainedValue()
}

private func takeValue<Instance>(fromCopied copied: Unmanaged<Instance>) -> Instance {
    defer {
        copied.release()
    }
    return copied.takeUnretainedValue()
}
