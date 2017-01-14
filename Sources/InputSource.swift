import Carbon

public struct InputSource {
    let tisInputSource: TISInputSource

    init(_ tisInputSource: TISInputSource) {
        self.tisInputSource = tisInputSource
    }

    private func value<T>(forProperty propertyKey: CFString, type: T.Type) -> T? {
        guard let value = TISGetInputSourceProperty(tisInputSource, propertyKey) else {
            return nil
        }
        return Unmanaged<AnyObject>.fromOpaque(value).takeUnretainedValue() as? T
    }

    public var filteringProperties: [TextInputSources.FilteringPropertyName: Any] {
        return [
            .category:         category,
            .kind:             kind,
            .asciiCapablility: isASCIICapable,
            .enableCapability: isEnableCapable,
            .selectCapability: isSelectCapable,
            .enabled:          isEnabled,
            .selected:         isSelected,
            .id:               id,
            .bundleID:         bundleID,
            .inputModeID:      inputModeID,
            .localizedName:    localizedName,
        ]
    }

    // MARK: - Properties (which can be used in filtering)

    public var category: Category {
        return value(forProperty: kTISPropertyInputSourceCategory, type: CFString.self).flatMap(Category.init)!
    }

    public var kind: Kind {
        return value(forProperty: kTISPropertyInputSourceType, type: CFString.self).flatMap(Kind.init)!
    }

    public var isASCIICapable: Bool {
        return value(forProperty: kTISPropertyInputSourceIsASCIICapable, type: CFBoolean.self)! as Bool
    }

    public var isEnableCapable: Bool {
        return value(forProperty: kTISPropertyInputSourceIsEnableCapable, type: CFBoolean.self)! as Bool
    }

    public var isSelectCapable: Bool {
        return value(forProperty: kTISPropertyInputSourceIsSelectCapable, type: CFBoolean.self)! as Bool
    }

    public var isEnabled: Bool {
        return value(forProperty: kTISPropertyInputSourceIsEnabled, type: CFBoolean.self)! as Bool
    }

    public var isSelected: Bool {
        return value(forProperty: kTISPropertyInputSourceIsSelected, type: CFBoolean.self)! as Bool
    }

    public var id: String {
        return value(forProperty: kTISPropertyInputSourceID, type: CFString.self)! as String
    }

    public var bundleID: String {
        return value(forProperty: kTISPropertyBundleID, type: CFString.self)! as String
    }

    public var inputModeID: String {
        return value(forProperty: kTISPropertyInputModeID, type: CFString.self)! as String
    }

    public var localizedName: String {
        return value(forProperty: kTISPropertyLocalizedName, type: CFString.self)! as String
    }

    // MARK: - Properties

    public var languages: [String] {
        return value(forProperty: kTISPropertyInputSourceLanguages, type: CFArray.self) as! [String]
    }

    public var locales: [Locale] {
        return languages
            .map { CFLocaleCreateCanonicalLanguageIdentifierFromString(kCFAllocatorDefault, $0 as CFString)! }
            .map { CFLocaleCreate(kCFAllocatorDefault, $0)! as Locale }
    }

    public var unicodeKeyLayout: UnsafePointer<UCKeyboardLayout>? {
        guard let data = value(forProperty: kTISPropertyUnicodeKeyLayoutData, type: CFData.self) else {
            return nil
        }
        return UnsafePointer<UCKeyboardLayout>(OpaquePointer(CFDataGetBytePtr(data)))
    }

    public var iconRef: IconRef? {
        guard let pointer = TISGetInputSourceProperty(tisInputSource, kTISPropertyIconRef) else {
            return nil
        }
        return IconRef(pointer)
    }

    public var iconImageURL: URL? {
        return value(forProperty: kTISPropertyIconImageURL, type: CFURL.self) as URL?
    }
}

extension InputSource: Equatable {
    public static func ==(lhs: InputSource, rhs: InputSource) -> Bool {
        return CFEqual(lhs.tisInputSource, rhs.tisInputSource)
    }
}

protocol FilteringPropertyValue {
    var internalValue: Any { get }
}

public extension InputSource {
    public enum Category: RawRepresentable, FilteringPropertyValue {
        case keyboard
        case palette
        case ink

        public var rawValue: CFString {
            switch self {
            case .keyboard: return kTISCategoryKeyboardInputSource
            case .palette:  return kTISCategoryPaletteInputSource
            case .ink:      return kTISCategoryInkInputSource
            }
        }

        public init?(rawValue: CFString) {
            switch rawValue as String {
            case String(kTISCategoryKeyboardInputSource): self = .keyboard
            case String(kTISCategoryPaletteInputSource):  self = .palette
            case String(kTISCategoryInkInputSource):      self = .ink
            default: return nil
            }
        }

        public var kinds: Set<Kind> {
            switch self {
            case .keyboard:
                return [.keyboardLayout, .keyboardInputMethodWithoutModes, .keyboardInputMethodModeEnabled, .keyboardInputMode]
            case .palette:
                return [.characterPalette, .keyboardViewer]
            case .ink:
                return [.ink]
            }
        }

        var internalValue: Any {
            return rawValue
        }
    }
}

public extension InputSource {
    public enum Kind: RawRepresentable, FilteringPropertyValue {
        case keyboardLayout
        case keyboardInputMethodWithoutModes
        case keyboardInputMethodModeEnabled
        case keyboardInputMode
        case characterPalette
        case keyboardViewer
        case ink

        public var rawValue: CFString {
            switch self {
            case .keyboardLayout:                  return kTISTypeKeyboardLayout
            case .keyboardInputMethodWithoutModes: return kTISTypeKeyboardInputMethodWithoutModes
            case .keyboardInputMethodModeEnabled:  return kTISTypeKeyboardInputMethodModeEnabled
            case .keyboardInputMode:               return kTISTypeKeyboardInputMode
            case .characterPalette:                return kTISTypeCharacterPalette
            case .keyboardViewer:                  return kTISTypeKeyboardViewer
            case .ink:                             return kTISTypeInk
            }
        }

        public init?(rawValue: CFString) {
            switch rawValue as String {
            case String(kTISTypeKeyboardLayout):                  self = .keyboardLayout
            case String(kTISTypeKeyboardInputMethodWithoutModes): self = .keyboardInputMethodWithoutModes
            case String(kTISTypeKeyboardInputMethodModeEnabled):  self = .keyboardInputMethodModeEnabled
            case String(kTISTypeKeyboardInputMode):               self = .keyboardInputMode
            case String(kTISTypeCharacterPalette):                self = .characterPalette
            case String(kTISTypeKeyboardViewer):                  self = .keyboardViewer
            case String(kTISTypeInk):                             self = .ink
            default: return nil
            }
        }

        public var category: Category {
            switch self {
            case .keyboardLayout, .keyboardInputMethodWithoutModes, .keyboardInputMethodModeEnabled, .keyboardInputMode:
                return .keyboard
            case .characterPalette, .keyboardViewer:
                return .palette
            case .ink:
                return .ink
            }
        }
        
        var internalValue: Any {
            return rawValue
        }
    }
}
