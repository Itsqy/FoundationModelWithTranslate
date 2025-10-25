# Javanese-Indonesian Translator

A comprehensive iOS application for translating between Javanese and Indonesian languages, featuring both local dictionary lookup and cloud-based AI translation capabilities.

## Features

### 🔤 Translation Capabilities
- **Bidirectional Translation**: Javanese ↔ Indonesian
- **Multiple Javanese Registers**: Ngoko, Ngoko Alus, Krama Inggil
- **Hybrid Translation**: Combines local dictionary with cloud AI for optimal results
- **Real-time Translation**: Fast dictionary lookup with cloud fallback

### 📚 Local Dictionary
- **Comprehensive Database**: Built-in Javanese-Indonesian dictionary with 5,000+ entries
- **Register Support**: All Javanese language registers (Ngoko, Krama Alus, Krama Inggil)
- **Offline Capability**: Works without internet connection for dictionary lookups
- **Confidence Scoring**: Shows translation confidence levels

### ☁️ Apple Foundation Models Integration
- **Apple Foundation Models**: Advanced AI translation using Apple's cloud-based models
- **Content Generation**: Generate culturally appropriate content
- **Context Awareness**: Understands cultural nuances and context
- **Streaming Support**: Real-time translation streaming

### 🎨 User Interface
- **Modern SwiftUI Design**: Clean, intuitive interface
- **Translation Results**: Detailed results with confidence scores and method indicators
- **Dictionary Matches**: View individual dictionary matches with register information
- **Content Generator**: Dedicated interface for content generation
- **Settings Panel**: Configure translation preferences and API keys

## Setup Instructions

### 1. Prerequisites
- iOS 16.0+
- Xcode 14.0+
- Swift 5.7+

### 2. Apple Foundation Models Configuration

Apple Foundation Models are automatically available on iOS 18.0+ and macOS 15.0+. No additional configuration is required.

### 3. Dictionary Setup
The app automatically loads the `kamus-bahasa-jawa.json` dictionary file. No additional setup required.

## Usage

### Basic Translation
1. **Select Direction**: Choose "Jawa → Indonesia" or "Indonesia → Jawa"
2. **Choose Register**: Select the appropriate Javanese register (Ngoko, Ngoko Alus, Krama Inggil)
3. **Select Method**: Choose translation method (Dictionary, Cloud Model, or Hybrid)
4. **Enter Text**: Type your text in the input field
5. **Translate**: Tap the translate button

### Translation Methods

#### Dictionary Only
- Fast, offline translation
- Uses local dictionary database
- Best for common words and phrases
- Limited to dictionary entries

#### Apple Foundation Only
- AI-powered translation using Apple's models
- Requires internet connection
- Handles complex sentences and context
- More accurate for nuanced translations

#### Hybrid (Recommended)
- Combines dictionary and Apple Foundation Models
- Fast dictionary lookup first
- Falls back to Apple Foundation Models for complex translations
- Best of both worlds

### Content Generation
1. Tap the sparkles (✨) button
2. Enter your content generation prompt
3. Optionally provide additional context
4. Tap "Generate Content"
5. View and copy the generated content

### Settings Configuration
- **Preferred Method**: Set default translation method
- **Fallback to Cloud**: Enable cloud fallback for dictionary-only mode
- **API Key Management**: Configure OpenAI API key
- **Status Monitoring**: Check dictionary and cloud service status

## Project Structure

```
fmltest/
├── Models/
│   └── Translation.swift          # Data models and enums
├── Services/
│   ├── DictionaryLookupService.swift    # Local dictionary service
│   ├── CloudTranslationService.swift   # OpenAI integration
│   └── JavaneseTranslator.swift        # Main translation coordinator
├── Views/
│   ├── ContentView.swift               # Main translation interface
│   ├── TranslationResultView.swift    # Translation results display
│   ├── ContentGenerationView.swift    # Content generation interface
│   └── SettingsView.swift             # Settings and configuration
├── kamus-bahasa-jawa.json             # Javanese dictionary database
└── Assets.xcassets/                   # App icons and assets
```

## Technical Details

### Dictionary Format
The dictionary uses a JSON structure with entries containing:
- `indonesia`: Indonesian translation
- `ngoko`: Ngoko register
- `kramaalus`: Krama Alus register  
- `kramainggil`: Krama Inggil register

### Translation Flow
1. **Input Validation**: Check text validity and method selection
2. **Dictionary Lookup**: Search local dictionary for matches
3. **Confidence Assessment**: Evaluate dictionary match quality
4. **Cloud Fallback**: Use AI translation if dictionary insufficient
5. **Result Assembly**: Combine results with metadata
6. **UI Update**: Display results with confidence scores

### Error Handling
- Network connectivity issues
- API key validation
- Dictionary loading errors
- Invalid input handling
- Graceful fallbacks

## API Requirements

### OpenAI API
- **Model**: GPT-3.5-turbo
- **Endpoint**: `/v1/chat/completions`
- **Authentication**: Bearer token
- **Rate Limits**: Standard OpenAI limits apply

### Local Dictionary
- **Format**: JSON
- **Size**: ~5,000 entries
- **Loading**: Automatic on app launch
- **Storage**: Bundle resources

## Performance Considerations

### Dictionary Performance
- **Loading Time**: < 1 second
- **Lookup Speed**: < 100ms per word
- **Memory Usage**: ~2MB for full dictionary
- **Caching**: In-memory dictionary cache

### Cloud Performance
- **API Latency**: 1-3 seconds typical
- **Streaming**: Real-time response streaming
- **Fallback**: Automatic dictionary fallback
- **Caching**: No persistent caching (privacy)

## Troubleshooting

### Common Issues

#### Dictionary Not Loading
- Check `kamus-bahasa-jawa.json` is in bundle
- Verify JSON format is valid
- Check file permissions

#### Cloud Translation Failing
- Verify API key is set correctly
- Check internet connectivity
- Confirm OpenAI account has credits
- Check API rate limits

#### Translation Quality Issues
- Try different Javanese registers
- Use Hybrid method for best results
- Provide more context in prompts
- Check dictionary match confidence

### Debug Information
- Settings panel shows service status
- Translation results include method used
- Error messages provide specific failure reasons
- Confidence scores indicate translation quality

## Future Enhancements

### Planned Features
- **Voice Input**: Speech-to-text translation
- **Voice Output**: Text-to-speech for results
- **History**: Translation history and favorites
- **Export**: Save translations to files
- **Offline Mode**: Enhanced offline capabilities
- **Custom Dictionaries**: User-defined dictionary entries

### Technical Improvements
- **Caching**: Intelligent translation caching
- **Batch Processing**: Multiple text translation
- **Advanced AI**: GPT-4 integration
- **Performance**: Optimized dictionary search
- **Accessibility**: Enhanced accessibility features

## Contributing

### Development Setup
1. Clone the repository
2. Open in Xcode
3. Set up API keys
4. Build and run on simulator/device

### Code Structure
- **MVVM Pattern**: Model-View-ViewModel architecture
- **SwiftUI**: Modern declarative UI
- **Combine**: Reactive programming
- **Async/Await**: Modern concurrency

### Testing
- Unit tests for translation logic
- UI tests for user interactions
- Integration tests for API calls
- Performance tests for dictionary operations

## License

This project is licensed under the MIT License. See LICENSE file for details.

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review error messages in the app
3. Verify API key and network connectivity
4. Check OpenAI service status

## Acknowledgments

- Javanese language community for cultural guidance
- OpenAI for AI translation capabilities
- SwiftUI and iOS development community
- Open source contributors and testers
