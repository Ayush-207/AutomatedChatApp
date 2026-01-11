# Swiggy Chat App - iOS Assignment
A fully-featured chat interface built with SwiftUI for iOS 17+, demonstrating modern iOS development practices with MVVM architecture, SwiftData persistence, and smooth animations.

## 📱 Features Implemented

### Core Requirements ✅

- **Message Display**
  - Chronological message ordering (oldest to newest)
  - Auto-scroll to latest message on load and new message send
  - Distinct UI alignment (User: right/blue, Agent: left/gray)
  - Formatted timestamps for each message

- **Message Types**
  - Text messages with bubble UI
  - Image messages with file size display
  - Thumbnail support for faster loading
  - Full-screen image viewer with pinch-to-zoom
  - Optional captions for images
  
- **Message Input**
  - Text input field with multi-line support
  - Send button (disabled when empty)
  - Attachment button for images from:
    - Photo Library
    - Camera
  - Image preview before sending
  
- **State Management**
  - MVVM architecture with `ChatViewModel`
  - SwiftUI state management using `@Published`, `@State`, `@ObservedObject`
  - Reactive UI updates

- **Local Persistence**
  - SwiftData for efficient message storage
  - Proper pagination with lazy loading
  - Seed data preloaded on first launch

### Bonus Features Implemented ✨

- **Smart Timestamp Formatting**
  - "Just now" for messages < 1 minute old
  - "X minutes ago" for recent messages
  - "Today at 2:30 PM" for today's messages
  - "Yesterday at 5:45 PM" for yesterday
  - "Monday at 3:15 PM" for this week
  - Full date for older messages

- **Typing Indicator**
  - Animated 3-dot indicator
  - Simulates agent typing for 2 seconds after user message
  - Smooth appearance/disappearance transitions

- **Pagination Support**
  - Loads 15 messages at a time from database
  - "Load More" button when scrolling up
  - Efficient lazy loading prevents loading all messages
  - Database-level pagination

- **Image Caching**
  - Memory cache using NSCache (100 images, 50MB limit)
  - Caches both remote and local images
  - Prevents redundant downloads and disk reads

- **Image Compression & Thumbnails**
  - Images compressed to 85% quality before saving
  - Automatic thumbnail generation (100px max dimension)
  - Thumbnails stored separately in cache directory
  - Custom `SwiggyChatImageView` handles thumbnail-first loading

- **Long-press to Copy**
  - Long-press any text message to copy
  - Works on both standalone text and image captions
  - Confirmation alert on copy

- **Smart Keyboard Behavior**
  - When at bottom: Chat shifts up seamlessly with keyboard
  - When scrolled up: Chat remains in place (preserves reading position)
  - Tap anywhere to dismiss keyboard

- **Fast scroll to last message button**
  - Appears when offset is greater than 100, fast scroll to bottom button like in Whatsapp.
    
## 🏗️ Architecture

### MVVM Pattern

```
Models/
├── Message.swift          // Message data model
├── MessageModel.swift     // SwiftData persistent model

ViewModels/
└── ChatViewModel.swift    // Business logic & state management

Views/
├── HomeView.swift         // Simple home navigation
├── ChatView.swift         // Chat detail page
├── MessageBubbleView.swift // Individual message rendering
├── MessageInputView.swift  // Input field & controls
├── FullScreenImageView.swift // Full-screen image viewer
├── TypingIndicatorView.swift // Animated typing dots
├── SwiggyChatImageView.swift // Custom cached image view
└── ImagePicker.swift      // Camera/Gallery picker

Services/
└── StorageService.swift   // SwiftData persistence layer
└── ImageService.swift     // Image caching & compression

Utilities/
└── Date+Extensions.swift  // Smart timestamp formatting
└── SeedData.swift         // Initial mock messages
```

## 📝 Architecture Decisions

### 1. **SwiftData over UserDefaults/CoreData**
   - **Benefits**: 
     - Native pagination support with `fetchLimit` and `fetchOffset`
     - Efficient memory usage (only loads needed messages)
     - Type-safe queries with `@Model` macro
     - Better suited for chat apps with potentially thousands of messages
     
### 2. **Custom Image Caching System**
   - **Implementation**:
     - NSCache for in-memory caching (fast access)
     - Thumbnail-first loading strategy
     - Separate cache/documents directories for original/thumbnails
     
### 3. **Completion Handler Pattern for Image Loading**
   - **Benefits**:
     - Works seamlessly with `@State` updates
     - Handles both local and remote images uniformly
     - Easy error handling
     
### 4.  **Custom Keyboard Behavior**
   - **Benefits**:
    - When at bottom: Chat shifts up seamlessly with keyboard
    - When scrolled up: Chat remains in place (preserves reading position)
    - Tap anywhere to dismiss keyboard
    
### 5. **Lazy Loading with Pagination**
   - **Implementation**:
     - Initial load: Last 15 messages
     - "Load More" fetches previous 15 messages
     - Database-level pagination (not in-memory filtering)
    
## 🎨 Key Implementation Details

### Message Storage
- **Original images**: Documents directory
- **Thumbnails**: Caches directory (can be cleared by system)
- **Messages**: SwiftData persistent store
- **Image cache**: In-memory NSCache (auto-evicts on memory pressure)

### Scroll Behavior
- Uses a custom logic based on bottom view origin and chat view height to detect scroll position
- Only auto-scrolls when user is at bottom of chat
- Preserves scroll position when viewing older messages

### Image Handling
1. Check memory cache
2. Thumbnail first logic, fallback to original for remote/local images.
3. Download and cache for remote/local images.
4. Update UI on main thread via completion handler

## 📸 Screenshots

<img width="295" height="639" alt="IMG_0504" src="https://github.com/user-attachments/assets/a5010408-a8e5-4618-af13-d84ea0caecd9" />
<img width="295" height="639" alt="IMG_0505" src="https://github.com/user-attachments/assets/824e7cb6-aa5d-471e-87a6-0f51da7d8118" />
<img width="295" height="639" alt="IMG_0506" src="https://github.com/user-attachments/assets/8d6b2597-5266-47cb-8504-ae84cf943f27" />
<img width="295" height="639" alt="IMG_0507" src="https://github.com/user-attachments/assets/c1167913-e788-4374-b59b-8907a0a1c34f" />
<img width="295" height="639" alt="IMG_0509" src="https://github.com/user-attachments/assets/fbbee38d-202a-4760-a515-1e7800908d9e" />
<img width="295" height="639" alt="IMG_0510" src="https://github.com/user-attachments/assets/cae7e0fe-c3bd-4a5d-a19f-83ca8336607b" />

## 🎯 Testing Notes

Tested Scenarios
* ✅ Sending text messages
* ✅ Sending images from gallery
* ✅ Sending images from camera
* ✅ Image with caption
* ✅ Long-press to copy text
* ✅ Full-screen image view with zoom
* ✅ Pagination (loading older messages)
* ✅ App restart (persistence)
* ✅ Keyboard behavior at bottom
* ✅ Keyboard behavior when scrolled up
* ✅ Emoji input
* ✅ Multi-line text input
* ✅ Network images (from seed data)
* ✅ Typing indicator
Device Compatibility
* ✅ iPhone SE (small screen)
* ✅ iPhone 15 Pro (standard)
* ✅ iPhone 15 Pro Max (large)

**📦 Dependencies**
None - Pure SwiftUI with native Apple frameworks:
* SwiftUI
* SwiftData
* UIKit (for image picker)
* Foundation

