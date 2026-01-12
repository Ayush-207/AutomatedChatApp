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
  - Automatic thumbnail generation (400px max dimension)
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
  
- **Time-based Message Grouping**
  - Messages grouped by date with only the first message in group having tail.
  - Improved readability for long conversation histories

- **Message Bubble Tails**
  - Professional chat UI with bubble pointers
  - Left-pointing tail for agent messages
  - Right-pointing tail for user messages
  - Coupled with time-based message grouping. Only shown for first message in a group.

- **Haptic Feedback**
  - Tactile feedback on message send
  - Selection feedback on button interactions
  - Enhances premium app feel

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
├── ChatScreenView.swift   // Chat detail page
├── ChatView.swift         // Message list view
├── MessageBubbleView.swift // Individual message rendering
├── MessageInputView.swift  // Input field & controls
├── FullScreenImageView.swift // Full-screen image viewer
├── TypingIndicatorView.swift // Animated typing dots
├── SwiggyChatImageView.swift // Custom cached image view
├── ImagePicker.swift      // Camera/Gallery picker
└── BubbleTailShape.swift      // Bubble tail shape for message bubble

Services/
└── StorageService.swift   // SwiftData persistence layer
└── ImageService.swift     // Image caching & compression
└── HapticManager.swift     // Handles Haptics

Utilities/
└── Extensions+Date.swift  // Smart timestamp formatting
└── SeedData.swift         // Initial mock messages
└── KeyboardObserver.swift // ObservableObject for observing keyboard events 
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
     - Database-level pagination

### 6. **Message Bubble Tails**
   - **Why**: Professional, familiar chat interface design
   - **Implementation**:
     - Custom `BubbleTailShape` using SwiftUI `Shape` protocol
     - Dynamic positioning based on message sender
     - Color-matched with bubble background
   - **Benefits**:
     - Clearer visual indication of message direction
     - Industry-standard chat UI pattern (WhatsApp, iMessage, Telegram)

### 7. **Time-based Message Grouping**
   - **Implementation**:
     - Messages grouped by date boundaries
     - Date only shown for last message in a group
     - Message Bubble Tail only shown for first message in a group.
     - Custom grouping logic based on timestamp comparison
   - **Benefits**:
     - Easy to navigate long conversations
     - Clear temporal context for messages
     - Reduced visual clutter

### 8. **Haptic Feedback System**
   - **Implementation**:
     - Centralized `HapticManager` singleton
     - Different feedback types (impact, selection)
     - Strategic placement on key interactions
   - **Benefits**:
     - Physical confirmation of actions
     - Enhanced perceived responsiveness
     - Modern iOS app standard
     
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

<p align="center">
  <img width="295" height="639" alt="IMG_0513" src="https://github.com/user-attachments/assets/4d977c38-5d91-4ca5-b780-b6b979aab661" />
</p>
<p align="center">
  <em>Chat Detail Page</em>
</p>

<p align="center">
  <img width="295" height="639" alt="IMG_0513" src="https://github.com/user-attachments/assets/fe784709-2eb2-4e8b-91cd-c6245fb0247e" />
</p>
<p align="center">
  <em>Image Picker</em>
</p>

<p align="center">
  <img width="295" height="639" alt="IMG_0516" src="https://github.com/user-attachments/assets/7ccf4dfb-188a-4829-a762-844f0b9f2caf" />
  <img width="295" height="639" alt="IMG_0517" src="https://github.com/user-attachments/assets/0f639151-28b6-44ba-af73-a97f88ade348" />
</p>
<p align="center">
  <em>Image from photo library</em>
</p>

<p align="center">
  <img width="295" height="639" alt="IMG_0519" src="https://github.com/user-attachments/assets/9d02ad87-d0a5-4a1b-8ade-451961ee9666" />
  <img width="295" height="639" alt="IMG_0520" src="https://github.com/user-attachments/assets/d43af7a5-cc8f-4d1e-8acd-8b4ce87bf411" />
</p>
<p align="center">
  <em>Image from camera</em>
</p>

<p align="center">
  <img width="295" height="639" alt="IMG_0530" src="https://github.com/user-attachments/assets/f2e4e86b-fadd-462a-802b-0e3afc83c55b" />
</p>
<p align="center">
  <em>Time based message grouping</em>
</p>

<p align="center">
<img width="295" height="639" alt="GIF_FullScreenView" src="https://github.com/user-attachments/assets/2efc4733-8e44-44b8-b373-8dbbbd0bc6dd" />
</p>
<p align="center">
  <em>Full Screen Image View</em>
</p>

<p align="center">
<img width="295" height="639" alt="GIF_FullScreenView" src="https://github.com/user-attachments/assets/e5a6b60d-0f96-406e-b62d-fb30389c3fdb" />
</p>
<p align="center">
  <em>Simulated Agent Typing</em>
</p>

<p align="center">
<img width="295" height="639" alt="GIF_FullScreenView" src="https://github.com/user-attachments/assets/df6aa14d-3e3e-4872-9fc2-ac3412ce308e" />
</p>
<p align="center">
  <em>Messages Load Chunking</em>
</p>

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

