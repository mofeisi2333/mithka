# Telegram Localization Mapping Review

Generated for the Telegram language-pack migration. Mapped strings use Telegram language-pack keys at runtime; unmapped strings keep Mithka localizations until reviewed.

- Total app strings: 989
- Mapped to Telegram keys: 171
- Unmapped app strings: 818

## Unmapped Strings

| Mithka key | English text | Similar Telegram concept candidates |
| --- | --- | --- |
| `aboutTelegramChannel` | Telegram Channel | Channel / ChannelSettings / ChannelMembers |
| `aboutTitle` | About | - |
| `aboutVersion` | Version {value1} | - |
| `aboutWebsite` | Website | - |
| `accountBackupCopied` | Pyrogram session copied | Copy; CurrentSession / OtherSessions |
| `accountBackupCopyPyrogramMessage` | This copies the active Telegram authorization session to the clipboard. Anyone with this string can sign in as this account. | Copy; CurrentSession / OtherSessions |
| `accountBackupCopyPyrogramSession` | Copy Pyrogram session | Copy; CurrentSession / OtherSessions |
| `accountBackupCopyPyrogramTitle` | Copy Pyrogram session? | Copy; CurrentSession / OtherSessions |
| `accountBackupCreate` | Back up current account to Keychain | - |
| `accountBackupDeleteMessage` | This removes the saved session from Keychain. The Telegram session is not revoked. | Delete / DeleteChat / DeleteAll / DeleteAllFrom; CurrentSession / OtherSessions; Save |
| `accountBackupDeleteInvalidSession` | Delete Saved Session | Delete / DeleteChat / DeleteAll / DeleteAllFrom; CurrentSession / OtherSessions; Save |
| `accountBackupDeleteTitle` | Delete saved session? | Delete / DeleteChat / DeleteAll / DeleteAllFrom; CurrentSession / OtherSessions; Save |
| `accountBackupEmpty` | No account sessions are backed up yet. | CurrentSession / OtherSessions |
| `accountBackupEnabled` | Back up accounts | - |
| `accountBackupFreshSessionCreate` | Create New Session | CurrentSession / OtherSessions |
| `accountBackupFreshSessionInteractive` | Continue the login step to finish creating the new session. | CurrentSession / OtherSessions; Login / Devices |
| `accountBackupFreshSessionMessage` | The restored session is ready. To avoid using the same Telegram session on multiple devices, Mithka can create a new session from it with QR login. Telegram may ask for your two-step verification password. | Devices / CurrentSession / OtherSessions; CurrentSession / OtherSessions; Login / Devices; TwoStepVerification / Password |
| `accountBackupFreshSessionReady` | Created a new session in slot {value1} | CurrentSession / OtherSessions |
| `accountBackupFreshSessionTitle` | Create a new session? | CurrentSession / OtherSessions |
| `accountBackupFreshSessionUseRestored` | Use Restored Session | CurrentSession / OtherSessions |
| `accountBackupFreshSessionWaiting` | Creating the new session... | CurrentSession / OtherSessions |
| `accountBackupInvalidImportedMessage` | This session string is no longer valid or may have been revoked. Please export a fresh session from a logged-in device. | Devices / CurrentSession / OtherSessions; CurrentSession / OtherSessions; Login / Devices |
| `accountBackupInvalidMessage` | The saved session for {value1} is no longer valid or may have been revoked. Delete this saved session from Keychain? | Delete / DeleteChat / DeleteAll / DeleteAllFrom; CurrentSession / OtherSessions; Save |
| `accountBackupInvalidTitle` | Session no longer valid | CurrentSession / OtherSessions |
| `accountBackupImported` | Imported to account slot {value1} | - |
| `accountBackupIOSOnly` | Account backup is available on iOS only. | - |
| `accountBackupLoadPyrogramConfirm` | Load Session | CurrentSession / OtherSessions |
| `accountBackupLoadPyrogramMessage` | Paste a Pyrogram-compatible Telegram session string. The session will be imported locally as an account if it is still valid. | CurrentSession / OtherSessions |
| `accountBackupLoadPyrogramPaste` | Paste | - |
| `accountBackupLoadPyrogramPlaceholder` | Pyrogram session string | CurrentSession / OtherSessions |
| `accountBackupLoadPyrogramSession` | Load Pyrogram session | CurrentSession / OtherSessions |
| `accountBackupLoadPyrogramTitle` | Load Pyrogram session | CurrentSession / OtherSessions |
| `accountBackupNotice` | Only the TDLib session file is stored in the device Keychain. Message databases, media, logs, and caches are not backed up. To transfer this Keychain item to a new device, restore from an encrypted device backup. | AttachDocument / SharedFilesTab; Devices / CurrentSession / OtherSessions; CurrentSession / OtherSessions |
| `accountBackupRestore` | Restore | - |
| `accountBackupRestoreAccount` | Restore saved account | Save |
| `accountBackupRestored` | Restored to account slot {value1} | - |
| `accountBackupRestoreMessage` | This imports the saved session as a new account. The session must still be active on Telegram servers. | CurrentSession / OtherSessions; Save |
| `accountBackupRestoreTitle` | Restore saved session? | CurrentSession / OtherSessions; Save |
| `accountBackupSaved` | Session saved ({value1}) | CurrentSession / OtherSessions; Save |
| `accountBackupSessions` | Saved Sessions | CurrentSession / OtherSessions; Save |
| `accountBackupTitle` | Account Backup | - |
| `accountBackupUserId` | User ID: {value1} | - |
| `addMembersDoneWithCount` | Done ({value1}) | Members / GroupMembers / ChannelMembers; Done; Add |
| `addMembersInviteMembersTitle` | Invite Members | Members / GroupMembers / ChannelMembers; Add |
| `addMembersInvitePermissionError` | Invite failed. You may not have permission. | Members / GroupMembers / ChannelMembers; Add |
| `addPeopleFindGroups` | Find Groups | Search / SearchMessages / NoResult; NewGroup / GroupMembers / Groups; Add |
| `addPeopleFindPeople` | Find People | Search / SearchMessages / NoResult; Add |
| `addPeopleGroupNameOrLinkPlaceholder` | Group name/link | NewGroup / GroupMembers / Groups; SharedLinksTab / ShareLink; Add |
| `addPeopleNoGroupsOrChannelsFound` | No groups or channels found | NewGroup / GroupMembers / Groups; Channel / ChannelSettings / ChannelMembers; Add |
| `addPeopleNoUsersFound` | No users found | Add |
| `addPeopleUsernameOrPhonePlaceholder` | Username/phone number | Add |
| `apiCredentialsCustomClientApi` | Custom Client API | - |
| `apiCredentialsDescription` | Off by default. When enabled, fill in your own Telegram client API credentials; they take effect on the next launch or after signing in again. Acceleration stays off until every field is filled in. | - |
| `apiCredentialsTitle` | Video and Download Acceleration | AttachVideo / Videos; Download / Downloaded |
| `appIconBlueGradient` | Blue Gradient | - |
| `appIconChangeFailed` | Failed to change app icon | - |
| `appIconDefault` | Default | - |
| `appIconPixel` | 8-bit Pixel | - |
| `appIconPurpleGradient` | Purple Gradient | - |
| `appIconTitle` | App Icon | - |
| `appIconUnsupported` | This platform or launcher may not support changing the app icon. | - |
| `appIconWhite` | Pure White | - |
| `appearanceAddFont` | Add Font | Add |
| `appearanceAddTextFont` | Add Text Font | Add |
| `appearanceCacheCleaned` | Cleaned | ClearHistory / ClearTelegramCache; ClearTelegramCache |
| `appearanceCacheFiles` | Cache Files | AttachDocument / SharedFilesTab; ClearTelegramCache |
| `appearanceCacheRefreshed` | Refreshed | ClearTelegramCache |
| `appearanceCapUnreadCountAt99` | Show 99+ after 99 | - |
| `appearanceChatList` | Chat List | - |
| `appearanceChatView` | Chat View | - |
| `appearanceCleanableSize` | Cleanable | - |
| `appearanceCleanUnusedFonts` | Clean Unused Fonts | ClearHistory / ClearTelegramCache |
| `appearanceClearTextFonts` | Clear Text Fonts | ClearHistory / ClearTelegramCache |
| `appearanceColor` | Color | - |
| `appearanceDisplay` | Display | - |
| `appearanceDownloadFailed` | Download failed | Download / Downloaded |
| `appearanceEmojiFont` | Emoji Font | Emoji |
| `appearanceEmojiFontCatalogDescription` | The font list comes from the iebb/emojifonts manifest. Selected fonts are downloaded from GitHub Releases. Previews come from Emojipedia. | Select / SelectChat / SelectContact; Emoji; Download / Downloaded |
| `appearanceFileCount` | {value1} | AttachDocument / SharedFilesTab |
| `appearanceFont` | Font | - |
| `appearanceFontCache` | Font Cache | ClearTelegramCache |
| `appearanceFontCacheDescription` | Manages only runtime-downloaded Google font caches. Files used by the current font chain, monospace font, and emoji font are kept. | AttachDocument / SharedFilesTab; Emoji; Download / Downloaded; ClearTelegramCache |
| `appearanceFontChainDescription` | Text fonts are applied in order across the interface. The emoji font is preferred for emoji. The monospace font is used for code blocks. | Emoji |
| `appearanceFontDownloadFailedName` | {value1} Â· Download failed | Download / Downloaded |
| `appearanceFontInUse` | In Use | - |
| `appearanceFontLoadFailed` | Failed to load | - |
| `appearanceFontSize` | Font Size | - |
| `appearanceFontUnused` | Unused | - |
| `appearanceGoogleDownloaded` | Google downloaded | Download / Downloaded |
| `appearanceGroupAssistantPosition` | Group Assistant Position | NewGroup / GroupMembers / Groups |
| `appearanceHidePhoneInSidebar` | Hide Phone Number in Sidebar | - |
| `appearanceInterfaceSize` | Interface Size | - |
| `appearanceInUseSize` | In Use | - |
| `appearanceManage` | Manage | - |
| `appearanceMergeConsecutiveImages` | Merge Consecutive Images | AttachPhoto / SharedPhotosAndVideos |
| `appearanceMode` | Mode | - |
| `appearanceMonospaceFont` | Monospace Font | - |
| `appearanceNoCleanableFonts` | Nothing to clean | ClearHistory / ClearTelegramCache |
| `appearanceNoDownloadedFontCache` | No downloaded font cache. | Download / Downloaded; ClearTelegramCache |
| `appearanceNoMatchingFonts` | No matching fonts | - |
| `appearanceRefreshCacheList` | Refresh Cache List | ClearTelegramCache |
| `appearanceRoundGroupAvatars` | Show Group Avatars as Circles | NewGroup / GroupMembers / Groups |
| `appearanceSearchFont` | Search fonts | Search / SearchMessages / NoResult |
| `appearanceShowChatFiltersOnTop` | Show Chat Filters at Top | - |
| `appearanceShowChatListSearch` | Show Chat List Search | Search / SearchMessages / NoResult |
| `appearanceShowEditAndReadMarks` | Show Edit and Read Marks | - |
| `appearanceShowGroupMemberTitles` | Show Group Member Titles | Members / GroupMembers / ChannelMembers; NewGroup / GroupMembers / Groups |
| `appearanceShowPremiumNameColor` | Show Premium Name Color | - |
| `appearanceShowPremiumStatusEmoji` | Show Premium Status Emoji | Emoji |
| `appearanceShowUnreadChatCount` | Show Unread Chat Count | - |
| `appearanceSize` | Size | - |
| `appearanceSystem` | System | - |
| `appearanceSystemEmojiFont` | System emoji font | Emoji |
| `appearanceTextFont` | Text Font | - |
| `appearanceTextFontOrderHint` | Text fonts are applied in order. Characters not covered continue using the system font. | - |
| `appearanceTextFontUnsetHint` | No text font set. Using the system default. | - |
| `appearanceTitle` | Appearance | - |
| `appearanceTotalSize` | Total Size | - |
| `appearanceUnreadBadge` | Unread Badge | - |
| `appLocaleArabic` | Ø§ÙØ¹Ø±Ø¨ÙØ© | - |
| `appLocaleEnglish` | English | - |
| `appLocaleFollowSystem` | Follow System | - |
| `appLocaleFrench` | FranÃ§ais | - |
| `appLocaleGerman` | Deutsch | - |
| `appLocaleHindi` | à¤¹à¤¿à¤¨à¥à¤¦à¥ | - |
| `appLocaleIndonesian` | Indonesia | - |
| `appLocaleItalian` | Italiano | - |
| `appLocaleJapanese` | æ¥æ¬èª | - |
| `appLocaleKorean` | íêµ­ì´ | - |
| `appLocaleMalay` | Melayu | - |
| `appLocalePortuguese` | PortuguÃªs | - |
| `appLocaleRussian` | Ð ÑÑÑÐºÐ¸Ð¹ | - |
| `appLocaleSimplifiedChinese` | ç®ä½ä¸­æ | - |
| `appLocaleSpanish` | EspaÃ±ol | - |
| `appLocaleThai` | à¹à¸à¸¢ | - |
| `appLocaleTraditionalChinese` | ç¹é«ä¸­æ | - |
| `appLocaleTurkish` | TÃ¼rkÃ§e | - |
| `appLocaleUkrainian` | Ð£ÐºÑÐ°ÑÐ½ÑÑÐºÐ° | - |
| `appLocaleVietnamese` | Tiáº¿ng Viá»t | - |
| `archivedChatsGroupAssistant` | Group Assistant | NewGroup / GroupMembers / Groups |
| `audioSearchChatTab` | Chats | Search / SearchMessages / NoResult; AttachMusic / AttachAudio |
| `audioSearchFailed` | Audio search failed | Search / SearchMessages / NoResult; AttachMusic / AttachAudio |
| `audioSearchFetchingSource` | Fetching sourceâ¦ | Search / SearchMessages / NoResult; AttachMusic / AttachAudio |
| `audioSearchNoResults` | No audio found | Search / SearchMessages / NoResult; AttachMusic / AttachAudio |
| `audioSearchPlaceholder` | Search songs, artists, or file names | Search / SearchMessages / NoResult; AttachMusic / SharedMusicTab; AttachMusic / AttachAudio; AttachDocument / SharedFilesTab |
| `audioSearchSendAudioFailed` | Failed to send audio | Search / SearchMessages / NoResult; AttachMusic / AttachAudio; SendMessage |
| `audioSearchTelegramAudioTitle` | Search Telegram Audio | Search / SearchMessages / NoResult; AttachMusic / AttachAudio |
| `authCodeExpiredRetry` | The verification code has expired. Please request a new one. | - |
| `authCodeSent` | Verification code sent | SendMessage |
| `authCodeSentByFlashCall` | You will receive a flash call | Call / VideoCall; SendMessage |
| `authCodeSentByPhoneCall` | Youâll receive a phone call with the verification code | Call / VideoCall; SendMessage |
| `authCodeSentBySms` | The verification code was sent by SMS | SendMessage |
| `authCodeSentToTelegramDevices` | The verification code was sent to your other Telegram devices | Devices / CurrentSession / OtherSessions; SendMessage |
| `authInvalidPassword` | Incorrect password | TwoStepVerification / Password |
| `authInvalidPhoneNumber` | Invalid phone number format | - |
| `authInvalidVerificationCode` | Incorrect verification code | - |
| `autoDeleteAfterOneDay` | 1 day | Delete / DeleteChat / DeleteAll / DeleteAllFrom |
| `autoDeleteAfterOneMonth` | 1 month | Delete / DeleteChat / DeleteAll / DeleteAllFrom |
| `autoDeleteAfterOneWeek` | 1 week | Delete / DeleteChat / DeleteAll / DeleteAllFrom |
| `autoDeleteDescription` | New messages will be automatically deleted from the chat after the set time. | Delete / DeleteChat / DeleteAll / DeleteAllFrom |
| `callAccept` | Accept | Call / VideoCall |
| `callCamera` | Camera | Call / VideoCall |
| `callConnecting` | Connectingâ¦ | Call / VideoCall |
| `callDecline` | Decline | Call / VideoCall |
| `callEnded` | Call ended | Call / VideoCall |
| `callEndToEndEncrypted` | End-to-end encrypted | Call / VideoCall |
| `callFrontCamera` | Front camera | Call / VideoCall |
| `callHangUp` | Hang up | Call / VideoCall |
| `callIncomingCallInvite` | invited you to a {value1} call | Call / VideoCall |
| `callMute` | Mute | Call / VideoCall; MuteNotifications / UnmuteNotifications |
| `callRearCamera` | Rear camera | Call / VideoCall |
| `callSelectCamera` | Select camera | Select / SelectChat / SelectContact; Call / VideoCall |
| `callSpeakerphone` | Speakerphone | Call / VideoCall |
| `callWaitingForInviteAccept` | Waiting for the other person to acceptâ¦ | Call / VideoCall |
| `channelsLoading` | Loading channelsâ¦ | Channel / ChannelSettings / ChannelMembers |
| `channelsNoTopicChannels` | No topic channels yet | Channel / ChannelSettings / ChannelMembers; Topics / ForumTopic |
| `chatAdminsOnlyPosting` | Only admins can post | - |
| `chatAllMembersMuted` | All members are muted | Members / GroupMembers / ChannelMembers; MuteNotifications / UnmuteNotifications |
| `chatAndOthersCount` |  and {value1} others | - |
| `chatAutoDeleteCountdown` | Message will be automatically deleted in {value1} | Delete / DeleteChat / DeleteAll / DeleteAllFrom |
| `chatButtonUnsupported` | This button isnât supported yet | - |
| `chatCannotSendMessages` | You canât send messages in this chat | SendMessage |
| `chatContactCallsOnly` | Calls are only supported with contacts | Contacts / AddContact / AttachContact; Call / VideoCall |
| `chatDeleteActionsDone` | Done | Delete / DeleteChat / DeleteAll / DeleteAllFrom; Done |
| `chatDeleteActionsFailed` | Could not apply action: {value1} | Delete / DeleteChat / DeleteAll / DeleteAllFrom |
| `chatDeleteMessagesQuestion` | Delete messages? | Delete / DeleteChat / DeleteAll / DeleteAllFrom |
| `chatDeleteOptionDeleteMessage` | Delete this message | Delete / DeleteChat / DeleteAll / DeleteAllFrom |
| `chatDeleteSelectedMessagesConfirmation` | Delete the selected {value1} messages? | Delete / DeleteChat / DeleteAll / DeleteAllFrom; Select / SelectChat / SelectContact |
| `chatDeleteSingleMessageQuestion` | Delete this message? | Delete / DeleteChat / DeleteAll / DeleteAllFrom |
| `chatEditMessageTitle` | Edit Message | - |
| `chatBlockUserConfirm` | Block user | ReportSpamUser / BlockedUsers / Unblock |
| `chatBlockUserDone` | User blocked and report sent | ReportChat / ReportSpam / ReportChatSent; ReportSpamUser / BlockedUsers / Unblock; SendMessage; Done |
| `chatBlockUserFailed` | Could not block user: {value1} | ReportSpamUser / BlockedUsers / Unblock |
| `chatBlockUserMessage` | Block this sender, report the message for review, and remove their messages from this chat immediately? | Delete / DeleteChat / DeleteAll / DeleteAllFrom; ReportChat / ReportSpam / ReportChatSent; ReportSpamUser / BlockedUsers / Unblock |
| `chatBlockUserTitle` | Block abusive user? | ReportSpamUser / BlockedUsers / Unblock |
| `chatForwardedToName` | Forwarded to {value1} | Forward / ForwardTo / ShareSendTo |
| `chatForwardFailed` | Forward failed: {value1} | Forward / ForwardTo / ShareSendTo |
| `chatForwardProtected` | This message is protected and canât be forwarded | Forward / ForwardTo / ShareSendTo |
| `chatForwardRemoveCaption` | Remove caption | Delete / DeleteChat / DeleteAll / DeleteAllFrom; Forward / ForwardTo / ShareSendTo |
| `chatForwardRemoveSender` | Remove sender | Delete / DeleteChat / DeleteAll / DeleteAllFrom; Forward / ForwardTo / ShareSendTo |
| `chatForwardToTitle` | Forward to | Forward / ForwardTo / ShareSendTo |
| `chatInfoAlbum` | Album | - |
| `chatInfoAutoDeleteMessages` | Auto-delete messages | Delete / DeleteChat / DeleteAll / DeleteAllFrom |
| `chatInfoAutoDeleteOff` | Off | Delete / DeleteChat / DeleteAll / DeleteAllFrom |
| `chatInfoAutoDeleteOneDay` | 1 day | Delete / DeleteChat / DeleteAll / DeleteAllFrom |
| `chatInfoAutoDeleteOneMonth` | 1 month | Delete / DeleteChat / DeleteAll / DeleteAllFrom |
| `chatInfoAutoDeleteSevenDays` | 7 days | Delete / DeleteChat / DeleteAll / DeleteAllFrom |
| `chatInfoChatFolders` | Chat folders | - |
| `chatInfoClearHistoryDescription` | This deletes the local chat history but does not leave the chat. | ClearHistory / ClearTelegramCache |
| `chatInfoClearHistoryIrreversibleWarning` | After clearing, history on this device canât be recovered. | ClearHistory / ClearTelegramCache; Devices / CurrentSession / OtherSessions |
| `chatInfoClearHistoryQuestion` | Clear chat history? | ClearHistory / ClearTelegramCache |
| `chatInfoConfirmAgain` | Confirm again | - |
| `chatInfoConfirmClearHistory` | Confirm clear | ClearHistory / ClearTelegramCache |
| `chatInfoCreate` | Create | - |
| `chatInfoCreateFolderFailed` | Couldnât create chat folder | - |
| `chatInfoCreateFolderTitle` | New Chat Folder | - |
| `chatInfoDisableExplicitFolderWarning` | Turning off explicit folders will remove this chat. If it still matches automatic folder rules, it will be added to the exclusions list. | Delete / DeleteChat / DeleteAll / DeleteAllFrom; Add |
| `chatInfoFolderName` | Folder {value1} | - |
| `chatInfoFolderNameLabel` | Folder name | - |
| `chatInfoGroupAlbum` | Group album | NewGroup / GroupMembers / Groups |
| `chatInfoGroupApps` | Group apps | NewGroup / GroupMembers / Groups |
| `chatInfoGroupChat` | Group chat | NewGroup / GroupMembers / Groups |
| `chatInfoGroupId` | Group ID: {value1} | NewGroup / GroupMembers / Groups |
| `chatInfoLoadFoldersFailed` | Couldnât load chat folders | - |
| `chatInfoManageGroup` | Manage group | NewGroup / GroupMembers / Groups |
| `chatInfoMoveToGroupAssistant` | Move to Group Assistant | NewGroup / GroupMembers / Groups |
| `chatInfoNewFolder` | New folder | - |
| `chatInfoNoFolders` | No chat folders yet | - |
| `chatInfoNotSearchable` | Not searchable | - |
| `chatInfoPinFailed` | Pin failed | PinMessage / PinToTop / PinnedMessages |
| `chatInfoPinFailedWithReason` | Pin failed: {value1} | PinMessage / PinToTop / PinnedMessages |
| `chatInfoPinLimit` | Limit | PinMessage / PinToTop / PinnedMessages |
| `chatInfoTitle` | Chat Info | - |
| `chatInlineSwitchButtonUnsupported` | Inline switch buttons arenât supported yet | - |
| `chatJoinRequestPending` | Join request sent, pending approval | SendMessage |
| `chatJoinRequestSent` | Join request sent | SendMessage |
| `chatListAddFriendOrGroup` | Add friend/group | NewGroup / GroupMembers / Groups; Contacts / AddContact / AttachContact; Add |
| `chatListBlockedPlaceholder` | [Blocked] | ReportSpamUser / BlockedUsers / Unblock |
| `chatListChannelName` | Channel name | Channel / ChannelSettings / ChannelMembers |
| `chatListCreateChannelFailed` | Failed to create channel | Channel / ChannelSettings / ChannelMembers |
| `chatListDeleteChatQuestion` | Delete chat? | Delete / DeleteChat / DeleteAll / DeleteAllFrom |
| `chatListLeaveAndDeleteGroupConfirmation` | Leave "{value1}" and delete its chat history from this device? | Delete / DeleteChat / DeleteAll / DeleteAllFrom; NewGroup / GroupMembers / Groups; Devices / CurrentSession / OtherSessions |
| `chatLoadingTopics` | Loading topics | Topics / ForumTopic |
| `chatMeLabel` | Me | - |
| `chatMemberCount` | {value1} members | Members / GroupMembers / ChannelMembers |
| `chatMembersRemoveFailedPermission` | Remove failed. You may not have permission. | Delete / DeleteChat / DeleteAll / DeleteAllFrom; Members / GroupMembers / ChannelMembers |
| `chatMembersRemoveMemberConfirmation` | Remove {value1} from the group? | Delete / DeleteChat / DeleteAll / DeleteAllFrom; Members / GroupMembers / ChannelMembers; NewGroup / GroupMembers / Groups |
| `chatMembersRemoveMemberTitle` | Remove Member | Delete / DeleteChat / DeleteAll / DeleteAllFrom; Members / GroupMembers / ChannelMembers |
| `chatMembersTitleWithCount` | Group Members ({value1}) | Members / GroupMembers / ChannelMembers; NewGroup / GroupMembers / Groups |
| `chatMenu` | Menu | - |
| `chatMessageRequired` | Message canât be empty | - |
| `chatMessagesForwardedCount` | Forwarded {value1} messages | Forward / ForwardTo / ShareSendTo |
| `chatMessagesSavedCount` | Saved {value1} messages | Save |
| `chatMoreActionsUnsupported` | More actions arenât supported yet | - |
| `chatReportConfirm` | Report | ReportChat / ReportSpam / ReportChatSent |
| `chatReportFailed` | Could not send report: {value1} | ReportChat / ReportSpam / ReportChatSent; SendMessage |
| `chatReportMessage` | Report this message as objectionable or abusive content? | ReportChat / ReportSpam / ReportChatSent |
| `chatReportSent` | Report sent | ReportChat / ReportSpam / ReportChatSent; SendMessage |
| `chatReportTitle` | Report content? | ReportChat / ReportSpam / ReportChatSent |
| `chatNewMessagesCount` | {value1} new messages | - |
| `chatNewMessagesDivider` | New messages below | - |
| `chatNoTopics` | No topics yet | Topics / ForumTopic |
| `chatOnlineWithinMonth` | Online within a month | Online |
| `chatOnlineWithinWeek` | Online within a week | Online |
| `chatPeopleDoingAction` | {value1} people activeâ¦ | - |
| `chatPeopleTyping` | {value1} people are typingâ¦ | Typing |
| `chatRecentlyOnline` | Recently online | Online |
| `chatRestrictedAcknowledge` | OK | - |
| `chatRestrictedLeaveFailed` | Failed to leave group: {value1} | NewGroup / GroupMembers / Groups |
| `chatRestrictedTelegramTosMessage` | This group canât be displayed because it violated Telegram's Terms of Service. You can go back or leave the group. | NewGroup / GroupMembers / Groups |
| `chatRestrictedTitle` | Safety notice | - |
| `chatSavedToSavedMessages` | Saved to Saved Messages | Save |
| `chatSaveFailed` | Save failed: {value1} | Save |
| `chatSelectedMessagesCount` | {value1} messages selected | Select / SelectChat / SelectContact |
| `chatSelectUntilHere` | Select up to here | Select / SelectChat / SelectContact |
| `chatsSearchBots` | Bots | Search / SearchMessages / NoResult; AttachBot / Bot |
| `chatsSearchNoResults` | No chats found | Search / SearchMessages / NoResult |
| `chatsSearchPlaceholder` | Search chats and contacts | Search / SearchMessages / NoResult; Contacts / AddContact / AttachContact |
| `chatsSearchPublicGroupsAndChannels` | Public groups/channels | Search / SearchMessages / NoResult; NewGroup / GroupMembers / Groups; Channel / ChannelSettings / ChannelMembers |
| `chatStickerAddSuccess` | Added to emoji | AttachSticker; Emoji; Add |
| `chatTodoSetFailed` | Failed to pin: {value1} | PinMessage / PinToTop / PinnedMessages |
| `chatTodoUnsetFailed` | Failed to unpin: {value1} | UnpinMessage / UnpinFromTop |
| `chatTranslateFailed` | Translation failed: {value1} | TranslateMessage |
| `chatActionChoosingContact` | choosing a contactâ¦ | Contacts / AddContact / AttachContact |
| `chatActionChoosingLocation` | choosing a locationâ¦ | AttachLocation |
| `chatActionChoosingSticker` | choosing a stickerâ¦ | AttachSticker |
| `chatActionPlayingGame` | playing a gameâ¦ | Play / Pause / Next |
| `chatActionRecordingVideo` | recording a videoâ¦ | AttachVideo / Videos |
| `chatActionRecordingVideoNote` | recording a video messageâ¦ | AttachVideo / Videos |
| `chatActionRecordingVoice` | recording voiceâ¦ | AttachAudio / VoiceMessages |
| `chatActionUploadingFile` | sending a fileâ¦ | AttachDocument / SharedFilesTab; SendMessage |
| `chatActionUploadingPhoto` | sending a photoâ¦ | AttachPhoto / SharedPhotosAndVideos; SendMessage |
| `chatActionUploadingVideo` | sending a videoâ¦ | AttachVideo / Videos; SendMessage |
| `chatActionUploadingVideoNote` | sending a video messageâ¦ | AttachVideo / Videos; SendMessage |
| `chatActionUploadingVoice` | sending voiceâ¦ | AttachAudio / VoiceMessages; SendMessage |
| `chatActionWatchingAnimations` | watching animationsâ¦ | - |
| `chatTyping` | Typingâ¦ | Typing |
| `chatUnmute` | Unmute | MuteNotifications / UnmuteNotifications |
| `chatUserFallbackName` | User {value1} | - |
| `chatUserLeftGroup` | {value1} left the group | NewGroup / GroupMembers / Groups |
| `chatUsersJoinedGroup` | {value1}{value2} joined the group | NewGroup / GroupMembers / Groups |
| `chatUserDoingAction` | {value1} is {value2} | - |
| `chatUserTyping` | {value1} is typingâ¦ | Typing |
| `chatYouAreMuted` | You are muted | MuteNotifications / UnmuteNotifications |
| `chatYouWereRemovedFromGroup` | You were removed from this group | NewGroup / GroupMembers / Groups |
| `checklistComposerAddTask` | Add task | Add |
| `checklistComposerNewChecklistTitle` | New checklist | - |
| `checklistComposerPremiumLimitHint` | Up to 30 items Â· Creating checklists requires Telegram Premium | - |
| `checklistComposerTaskLabel` | Task {value1} | - |
| `checklistComposerTitleLabel` | Checklist title | - |
| `commonUiDraftBadge` | [Draft] | - |
| `commonUiGroupOwner` | Group owner | NewGroup / GroupMembers / Groups |
| `commonUiMentionedBySomeoneBadge` | [Someone mentioned me] | - |
| `commonUiMentionMeBadge` | [@me] | - |
| `commonUiNewFileBadge` | [New file] | AttachDocument / SharedFilesTab |
| `composerChecklist` | Checklist | - |
| `composerClipboardNoImage` | No image on clipboard | AttachPhoto / SharedPhotosAndVideos |
| `composerFilePreview` | [File]{value1} | AttachDocument / SharedFilesTab |
| `composerHoldToTalk` | Hold to talk | - |
| `composerImage` | Image | AttachPhoto / SharedPhotosAndVideos |
| `composerLoadingEmoji` | Loading emojiâ¦ | Emoji |
| `composerLocation` | Location | AttachLocation |
| `composerMarkdownSupportHint` | Markdown supported: **bold**, *italic*, `code`, quotes, and more | - |
| `composerMicrophonePermissionRequired` | Microphone permission required | - |
| `composerMicrophonePermissionSettings` | Allow microphone access in system settings | Settings |
| `composerNoEmoji` | No emoji yet | Emoji |
| `composerOpenAttachmentFailed` | Cannot open {value1} | - |
| `composerOpenMenu` | Open menu | - |
| `composerPaidMessageCost` | Sending this message costs {value1} Stars. | SendMessage |
| `composerPastedImageReadFailed` | Could not read pasted image | AttachPhoto / SharedPhotosAndVideos |
| `composerReleaseFingerToCancel` | Release to cancel | Cancel |
| `composerReleaseToSendSlideToCancel` | Release to send, slide up to cancel | SendMessage; Cancel |
| `composerRichText` | Rich text | - |
| `composerRichTextMessageTitle` | Rich text message | - |
| `composerSendPaidMessageQuestion` | Send paid message? | SendMessage |
| `confirmOk` | OK | - |
| `contactsFriends` | Friends | Contacts / AddContact / AttachContact |
| `contactsLoading` | Loadingâ¦ | Contacts / AddContact / AttachContact |
| `contactsNoBots` | No bots yet | Contacts / AddContact / AttachContact; AttachBot / Bot |
| `contactsNoChannels` | No channels yet | Channel / ChannelSettings / ChannelMembers; Contacts / AddContact / AttachContact |
| `contactsNoContacts` | No contacts yet | Contacts / AddContact / AttachContact |
| `contactsNoGroupChats` | No group chats yet | NewGroup / GroupMembers / Groups; Contacts / AddContact / AttachContact |
| `countryPickerSearchPlaceholder` | Search country / calling code | Search / SearchMessages / NoResult; Call / VideoCall |
| `countryPickerSelectCountryOrRegion` | Select country or region | Select / SelectChat / SelectContact |
| `createGroupFailed` | Failed to create group chat | NewGroup / GroupMembers / Groups |
| `createGroupOptionalLabel` | Optional | NewGroup / GroupMembers / Groups |
| `createGroupStartGroupChat` | Start group chat | NewGroup / GroupMembers / Groups |
| `editProfileAnimatedAvatar` | Animated avatar | - |
| `editProfileAnimatedAvatarDescription` | Use a short video as your avatar | AttachVideo / Videos |
| `editProfileAvatarUpdated` | Avatar updated | - |
| `editProfileAvatarUpdateFailed` | Failed to update avatar: {value1} | - |
| `editProfileBio` | Bio | - |
| `editProfileBioPlaceholder` | Tell people about yourself | - |
| `editProfileBirthDay` | {value1} | - |
| `editProfileBirthMonth` | {value1} | - |
| `editProfileBirthYear` | {value1} | - |
| `editProfileChangeAvatar` | Change avatar | - |
| `editProfileChooseAvatarType` | Choose avatar type | - |
| `editProfileChangeBio` | Edit bio | - |
| `editProfileChangeName` | Edit name | - |
| `editProfileChangeUsername` | Edit username | - |
| `editProfileClearBirthday` | Clear birthday | ClearHistory / ClearTelegramCache |
| `editProfileDefault` | Default | - |
| `editProfileInvalidAvatarFile` | Invalid avatar file | AttachDocument / SharedFilesTab |
| `editProfileNameColor` | Name color | - |
| `editProfileNameColorDescription` | Used for your name and message sidebar. | - |
| `editProfileNoBirthYear` | No year | - |
| `editProfileNotBound` | Not linked | - |
| `editProfilePhone` | Phone | - |
| `editProfileProfileColor` | Profile color | - |
| `editProfileProfileColorDescription` | Used for your profile page background. | - |
| `editProfileSaveFailed` | Failed to save | Save |
| `editProfileSetUsername` | Set username | - |
| `editProfileStaticAvatar` | Photo avatar | AttachPhoto / SharedPhotosAndVideos |
| `editProfileStaticAvatarDescription` | Crop and upload a still image | AttachPhoto / SharedPhotosAndVideos |
| `editProfileTapToFillBio` | Tap to add bio | Add |
| `editProfileTitle` | Edit profile | - |
| `editProfileUsername` | Username | - |
| `editProfileUsernameUnavailable` | Username unavailable | - |
| `editProfileUsernameUnsetHandle` | @not set | - |
| `emojiCategoryActivitiesAndSports` | Activities & Sports | Emoji |
| `emojiCategoryAnimalsAndNature` | Animals & Nature | Emoji |
| `emojiCategoryFoodAndDrink` | Food & Drink | Emoji |
| `emojiCategoryObjects` | Objects | Emoji |
| `emojiCategoryPeopleAndBody` | People & Body | Emoji |
| `emojiCategorySmileysAndEmotion` | Smileys & Emotion | Emoji |
| `emojiCategorySymbols` | Symbols | Emoji |
| `emojiCategoryTravelAndPlaces` | Travel & Places | Emoji |
| `emojiFontCatalogSystemDefault` | System default | Emoji |
| `emojiPreviewFaceWithTearsOfJoy` | Face with tears of joy | Emoji |
| `emojiStatusClear` | Clear | ClearHistory / ClearTelegramCache; Emoji |
| `emojiStatusNoAvailableStatuses` | No available statuses in this emoji pack | Emoji |
| `emojiStatusNoAvailableStatusesPremiumRequired` | No available statuses (Premium required) | Emoji |
| `emojiStatusSetRequiresPremiumFailed` | Failed to set status (Premium required) | Emoji |
| `emojiStatusSetTitle` | Set status | Emoji |
| `developerModePiPBoundsOverlay` | PiP bounds overlay | - |
| `developerModePiPBoundsOverlayDescription` | Shows the app-level PiP frame and viewport size to diagnose rotation, clipping, or overlay coverage. | - |
| `developerModeTitle` | Developer Mode | - |
| `developerModeUnlocked` | Developer Mode unlocked | - |
| `featureBottomTabs` | Bottom tabs | - |
| `featureTitle` | Features | - |
| `fileDetailDownloadProgress` | Downloading fileâ¦ ({value1}/{value2}) | AttachDocument / SharedFilesTab; Download / Downloaded |
| `fileDetailNoAppCanOpenFile` | No app can open this file | AttachDocument / SharedFilesTab |
| `fileDetailOpen` | Open | AttachDocument / SharedFilesTab |
| `generalCacheSize` | Cache size | ClearTelegramCache |
| `generalClearCache` | Clear cache | ClearHistory / ClearTelegramCache; ClearTelegramCache |
| `generalClearingCache` | Clearingâ¦ | ClearTelegramCache |
| `generalAutoDownloadDisabled` | Disabled | Download / Downloaded |
| `generalAutoDownloadFailed` | Failed to update auto-download settings | Download / Downloaded; Settings |
| `generalAutoDownloadHighResImages` | High-resolution images | AttachPhoto / SharedPhotosAndVideos; Download / Downloaded |
| `generalAutoDownloadMedia` | Auto-download media | Download / Downloaded |
| `generalAutoDownloadMobileData` | Mobile data | Download / Downloaded |
| `generalAutoDownloadWifi` | Wi-Fi | Download / Downloaded |
| `generalOpenChatAtLatestMessage` | Open chats at latest message | - |
| `generalSendMessageWithEnter` | Send messages with Enter | SendMessage |
| `generalStorage` | Storage | - |
| `generalTitle` | General | - |
| `groupManagementAdminApprovalRequired` | Admin approval required | NewGroup / GroupMembers / Groups |
| `groupManagementBasicSection` | Basic management | NewGroup / GroupMembers / Groups |
| `groupManagementEditable` | Editable | NewGroup / GroupMembers / Groups |
| `groupManagementEditFailed` | Failed to update | NewGroup / GroupMembers / Groups |
| `groupManagementGroupName` | Group name | NewGroup / GroupMembers / Groups |
| `groupManagementInviteLinkQr` | Invite link / QR code | NewGroup / GroupMembers / Groups; SharedLinksTab / ShareLink |
| `groupManagementJoinBeforePosting` | Join before posting | NewGroup / GroupMembers / Groups |
| `groupManagementJoinSection` | Join settings | NewGroup / GroupMembers / Groups; Settings |
| `groupManagementLoadFailed` | Failed to load group management | NewGroup / GroupMembers / Groups |
| `groupManagementLogAdmin` | Admin | NewGroup / GroupMembers / Groups |
| `groupManagementLogApprovedJoinRequest` | Approved join request | NewGroup / GroupMembers / Groups |
| `groupManagementLogChangedAdmin` | Changed admin | NewGroup / GroupMembers / Groups |
| `groupManagementLogChangedGroupDescription` | Changed group description | NewGroup / GroupMembers / Groups |
| `groupManagementLogChangedGroupName` | Changed group name | NewGroup / GroupMembers / Groups |
| `groupManagementLogChangedGroupPhoto` | Changed group photo | NewGroup / GroupMembers / Groups; AttachPhoto / SharedPhotosAndVideos |
| `groupManagementLogChangedLinkedChat` | Changed linked chat | NewGroup / GroupMembers / Groups |
| `groupManagementLogChangedMemberPermissions` | Changed member permissions | Members / GroupMembers / ChannelMembers; NewGroup / GroupMembers / Groups |
| `groupManagementLogChangedPostingPermissions` | Changed posting permissions | NewGroup / GroupMembers / Groups |
| `groupManagementLogChangedPublicUsername` | Changed public username | NewGroup / GroupMembers / Groups |
| `groupManagementLogChangedSlowMode` | Changed slow mode | NewGroup / GroupMembers / Groups |
| `groupManagementLogCreatedTopic` | Created topic | NewGroup / GroupMembers / Groups; Topics / ForumTopic |
| `groupManagementLogDeletedInviteLink` | Deleted invite link | NewGroup / GroupMembers / Groups; SharedLinksTab / ShareLink |
| `groupManagementLogDeletedMessage` | Deleted message | NewGroup / GroupMembers / Groups |
| `groupManagementLogDeletedTopic` | Deleted topic | NewGroup / GroupMembers / Groups; Topics / ForumTopic |
| `groupManagementLogEditedInviteLink` | Edited invite link | NewGroup / GroupMembers / Groups; SharedLinksTab / ShareLink |
| `groupManagementLogEditedMessage` | Edited message | NewGroup / GroupMembers / Groups |
| `groupManagementLogEditedTopic` | Edited topic | NewGroup / GroupMembers / Groups; Topics / ForumTopic |
| `groupManagementLogEmpty` | No management log yet | NewGroup / GroupMembers / Groups |
| `groupManagementLogEndedVideoChat` | Ended video chat | NewGroup / GroupMembers / Groups; AttachVideo / Videos |
| `groupManagementLogGenericAdminAction` | Performed an admin action | NewGroup / GroupMembers / Groups |
| `groupManagementLogInvitedMember` | Invited member | Members / GroupMembers / ChannelMembers; NewGroup / GroupMembers / Groups |
| `groupManagementLogJoinedByInviteLink` | Joined via invite link | NewGroup / GroupMembers / Groups; SharedLinksTab / ShareLink |
| `groupManagementLogJoinedGroup` | Joined the group | NewGroup / GroupMembers / Groups |
| `groupManagementLogLeftGroup` | Left the group | NewGroup / GroupMembers / Groups |
| `groupManagementLogNoPermission` | You do not have permission to view the group management log | NewGroup / GroupMembers / Groups |
| `groupManagementLogPinnedMessage` | Pinned message | PinMessage / PinToTop / PinnedMessages; NewGroup / GroupMembers / Groups |
| `groupManagementLogRevokedInviteLink` | Revoked invite link | NewGroup / GroupMembers / Groups; SharedLinksTab / ShareLink |
| `groupManagementLogStartedVideoChat` | Started video chat | NewGroup / GroupMembers / Groups; AttachVideo / Videos |
| `groupManagementLogTitle` | Group Management Log | NewGroup / GroupMembers / Groups |
| `groupManagementLogUnpinnedMessage` | Unpinned message | UnpinMessage / UnpinFromTop; NewGroup / GroupMembers / Groups |
| `groupManagementMembers` | Members | Members / GroupMembers / ChannelMembers; NewGroup / GroupMembers / Groups |
| `groupManagementMembersSection` | Member Management | Members / GroupMembers / ChannelMembers; NewGroup / GroupMembers / Groups |
| `groupManagementNoEditInfoPermission` | No permission to edit group info | NewGroup / GroupMembers / Groups |
| `groupManagementNotSet` | Not set | NewGroup / GroupMembers / Groups |
| `groupManagementPermissionCreateTopics` | Create topics | NewGroup / GroupMembers / Groups; Topics / ForumTopic |
| `groupManagementPermissionEditGroupInfo` | Edit group info | NewGroup / GroupMembers / Groups |
| `groupManagementPermissionLinkPreviews` | Link previews | NewGroup / GroupMembers / Groups; SharedLinksTab / ShareLink |
| `groupManagementPermissionPinMessages` | Pin messages | PinMessage / PinToTop / PinnedMessages; NewGroup / GroupMembers / Groups |
| `groupManagementPermissionSendFiles` | Send files | NewGroup / GroupMembers / Groups; AttachDocument / SharedFilesTab; SendMessage |
| `groupManagementPermissionSendMessages` | Send messages | NewGroup / GroupMembers / Groups; SendMessage |
| `groupManagementPermissionSendMusic` | Send music | NewGroup / GroupMembers / Groups; AttachMusic / SharedMusicTab; SendMessage |
| `groupManagementPermissionSendPhotos` | Send photos | NewGroup / GroupMembers / Groups; AttachPhoto / SharedPhotosAndVideos; SendMessage |
| `groupManagementPermissionSendPolls` | Send polls | NewGroup / GroupMembers / Groups; Poll; SendMessage |
| `groupManagementPermissionSendStickersAndGifs` | Send stickers and GIFs | NewGroup / GroupMembers / Groups; AttachSticker; AttachGif; SendMessage |
| `groupManagementPermissionSendVideoMessages` | Send video messages | NewGroup / GroupMembers / Groups; AttachVideo / Videos; SendMessage |
| `groupManagementPermissionSendVideos` | Send videos | NewGroup / GroupMembers / Groups; AttachVideo / Videos; SendMessage |
| `groupManagementPermissionSendVoice` | Send voice messages | NewGroup / GroupMembers / Groups; AttachAudio / VoiceMessages; SendMessage |
| `groupManagementPermissionSetFailed` | Failed to set permissions | NewGroup / GroupMembers / Groups |
| `groupManagementPostingPermissions` | Posting Permissions | NewGroup / GroupMembers / Groups |
| `groupManagementPublicUsername` | Public Username | NewGroup / GroupMembers / Groups |
| `groupManagementReadOnly` | Read-only | NewGroup / GroupMembers / Groups |
| `groupManagementSetFailed` | Setup failed | NewGroup / GroupMembers / Groups |
| `groupManagementUsernameUnavailableOrForbidden` | Username is unavailable or not allowed | NewGroup / GroupMembers / Groups |
| `imageEditAdd` | Add | AttachPhoto / SharedPhotosAndVideos; Add |
| `imageEditAddText` | Add text | AttachPhoto / SharedPhotosAndVideos; Add |
| `imageEditBrush` | Brush | AttachPhoto / SharedPhotosAndVideos |
| `imageEditCaptionInputPlaceholder` | Enter caption | AttachPhoto / SharedPhotosAndVideos |
| `imageEditCrop` | Crop | AttachPhoto / SharedPhotosAndVideos |
| `imageEditCropAvatar` | Crop avatar | AttachPhoto / SharedPhotosAndVideos |
| `imageEditDescriptionPlaceholder` | Add description... | AttachPhoto / SharedPhotosAndVideos; Add |
| `imageEditObscure` | Obscure | AttachPhoto / SharedPhotosAndVideos |
| `imageEditProcessing` | Processing... | AttachPhoto / SharedPhotosAndVideos |
| `imageEditResetCrop` | Reset crop | AttachPhoto / SharedPhotosAndVideos |
| `imageEditRotate` | Rotate | AttachPhoto / SharedPhotosAndVideos |
| `imageEditTextTool` | Text | AttachPhoto / SharedPhotosAndVideos |
| `imageEditTitle` | Edit Image | AttachPhoto / SharedPhotosAndVideos |
| `keywordBlockerDescription` | After you add keywords, matching messages will be hidden in chats and will not trigger local notifications. Supports plain keywords, re:regex, regex:regex, and /regex/i. Remote lists use one rule per line; lines starting with # or // are comments. | CommentsTitle / Comments; Notifications / GroupNotifications; Add |
| `keywordBlockerDownload` | Download | Download / Downloaded |
| `keywordBlockerDownloadFailed` | Failed to download keyword list | Download / Downloaded |
| `keywordBlockerInputPlaceholder` | Enter keyword | - |
| `keywordBlockerListUrl` | Keyword list URL | SharedLinksTab / ShareLink |
| `keywordBlockerAddFromMessageTitle` | Block keyword | ReportSpamUser / BlockedUsers / Unblock; Add |
| `keywordBlockerRuleAdded` | Blocked keyword: {value1} | ReportSpamUser / BlockedUsers / Unblock; Add |
| `keywordBlockerRulesAdded` | Added {value1} rules | Add |
| `keywordBlockerRulesUpToDate` | Rules are up to date | - |
| `keywordBlockerTitle` | Keyword Blocker | - |
| `languageTitle` | Language | Language / LanguageName |
| `languageMithkaLanguage` | Mithka language | Language / LanguageName |
| `languageTelegramFollowMithka` | Follow Mithka language | Language / LanguageName |
| `languageTelegramLanguage` | Telegram language | Language / LanguageName |
| `languageTelegramLoadFailed` | Failed to load Telegram languages | Language / LanguageName |
| `languageTelegramLoading` | Loading Telegram languagesâ¦ | Language / LanguageName |
| `languageTelegramOfficial` | Official | Language / LanguageName |
| `languageTelegramUsing` | Using {value1} | Language / LanguageName |
| `linkHandlerGroupLabel` | Group | NewGroup / GroupMembers / Groups; SharedLinksTab / ShareLink |
| `linkHandlerJoin` | Join | SharedLinksTab / ShareLink |
| `linkHandlerJoinNamedGroupQuestion` | Join "{value1}"? | NewGroup / GroupMembers / Groups; SharedLinksTab / ShareLink |
| `linkHandlerOpenTelegramLinkFailed` | Unable to open Telegram link | SharedLinksTab / ShareLink |
| `linkHandlerQrLoginWarning` | This link can approve another device signing in to your Telegram account. Make sure it is you signing in. | SharedLinksTab / ShareLink; Devices / CurrentSession / OtherSessions; Login / Devices |
| `linkHandlerUnsupportedTelegramLink` | Opening this Telegram link is not supported yet | SharedLinksTab / ShareLink |
| `listSeparator` | ,  | - |
| `locationDetailFetchingLocation` | Getting location... | AttachLocation |
| `locationPickerDragMapToChoose` | Drag the map to choose a location | AttachLocation |
| `loginBackToAccount` | Back to {value1} | Login / Devices |
| `loginBackToPreviousAccount` | Back to previous account | Login / Devices |
| `loginCodeSentByEmail` | Enter the code sent to your email. | Login / Devices; SendMessage |
| `loginCodeSentByFirebase` | Enter the code from the system verification prompt. | Login / Devices; SendMessage |
| `loginCodeSentByFlashCall` | Enter the code from the incoming call matching {value1}. | Call / VideoCall; Login / Devices; SendMessage |
| `loginCodeSentByFragment` | Enter the code from Fragment. | Login / Devices; SendMessage |
| `loginCodeSentByMissedCall` | Enter the last {value2} digits of the missed call from {value1}. | Call / VideoCall; Login / Devices; SendMessage |
| `loginCodeSentByPhoneCall` | Enter the code from the phone call to {value1}. | Call / VideoCall; Login / Devices; SendMessage |
| `loginCodeSentBySms` | Enter the SMS code sent to {value1}. | Login / Devices; SendMessage |
| `loginCodeSentFallback` | Enter the verification code. | Login / Devices; SendMessage |
| `loginCodeSentToTelegramDevices` | Enter the code sent to your other Telegram devices. | Devices / CurrentSession / OtherSessions; Login / Devices; SendMessage |
| `loginCodeWillBeSentToNumber` | We will send a one-time login code to this number | Login / Devices; SendMessage |
| `loginCompleteRegistration` | Complete registration | Login / Devices |
| `loginConfigureCustomApi` | Configure custom API | Login / Devices |
| `loginFirstName` | First name | Login / Devices |
| `loginGetVerificationCode` | Get code | Login / Devices |
| `loginLastNameOptional` | Last name (optional) | Login / Devices |
| `loginNewAccountNicknamePrompt` | This is a new account. Please enter a nickname | Login / Devices |
| `loginPasswordHint` | Password hint: {value1} | Login / Devices; TwoStepVerification / Password |
| `loginPhoneNumberWithCountryCode` | Phone number with country code | Login / Devices |
| `loginQrCodeSubtitle` | Scan this QR code with another phone already signed in to Telegram. | Login / Devices |
| `loginQrCodeTitle` | QR Code Login | Login / Devices |
| `loginReenterPhoneNumber` | Re-enter phone number | Login / Devices |
| `loginRefreshQrCode` | Refresh QR code | Login / Devices |
| `loginResendVerificationCode` | Resend code | Login / Devices |
| `loginSubmit` | Log In | Login / Devices |
| `loginSwitchAccount` | Switch account | Login / Devices |
| `loginTelegramAccountTitle` | Log in to Telegram | Login / Devices |
| `loginTelegramApiCredentialsMissing` | Telegram API credentials are not configured | Login / Devices |
| `loginTelegramApiPortalInstructions` | (You can get them from my.telegram.org.) | Login / Devices |
| `loginTelegramApiSecretsInstructions` | Enter your own Telegram client api_id and api_hash | Login / Devices |
| `loginTermsAccept` | Agree and continue | Login / Devices |
| `loginTermsBody` | By using this app, you must follow Telegram's Terms of Service. Mithka signs in to existing Telegram accounts and has zero tolerance for objectionable content or abusive users. You can filter messages with Keyword Blocker, report objectionable content through Telegram, and block abusive users through Telegram. Blocking removes that sender's messages from your view immediately. | ReportChat / ReportSpam / ReportChatSent; ReportSpamUser / BlockedUsers / Unblock; Login / Devices |
| `loginTermsButton` | Terms of Service | Login / Devices |
| `loginTermsOpenTelegram` | Open Telegram Terms of Service | Login / Devices |
| `loginTermsTitle` | Telegram Terms of Use | Login / Devices |
| `loginTwoStepPassword` | Two-step verification password | Login / Devices; TwoStepVerification / Password |
| `loginVerificationCode` | Verification code | Login / Devices |
| `loginVerify` | Verify | Login / Devices |
| `loginWithQrCode` | Log in with QR code | Login / Devices |
| `markdownLabel` | Markdown | - |
| `messageActionBlockKeyword` | Block keyword | ReportSpamUser / BlockedUsers / Unblock |
| `messageActionPlayMuted` | Play muted | MuteNotifications / UnmuteNotifications; Play / Pause / Next |
| `messageBubbleCallCanceled` | Canceled | Call / VideoCall |
| `messageBubbleCallDeclined` | Declined | Call / VideoCall |
| `messageBubbleCallDeclinedByOther` | Declined by the other person | Call / VideoCall |
| `messageBubbleCallDuration` | Call duration {value1} | Call / VideoCall |
| `messageBubbleCallMissed` | Missed | Call / VideoCall |
| `messageBubbleCallNoAnswer` | No answer | Call / VideoCall |
| `messageBubbleCollapse` | Collapse | - |
| `messageBubbleExpandQuote` | Expand quote | QuoteMessage |
| `messageBubbleTranslating` | Translatingâ¦ | - |
| `messageRepliesEmpty` | No replies yet | RepliesTitle / Replies |
| `messageRepliesTitle` | Replies | RepliesTitle / Replies |
| `messageRepliesUnavailable` | Replies are not available for this message | RepliesTitle / Replies |
| `momentsCommentCount` | {value1} comments | CommentsTitle / Comments |
| `momentsCommentPlaceholder` | Say something... | CommentsTitle / Comments |
| `momentsCreatePostTitle` | Create post | - |
| `momentsDetails` | Details | - |
| `momentsLiked` | Liked | - |
| `momentsLikedByCount` | Liked by {value1} | - |
| `momentsLikedByListWithOthers` | {value1}, ... and {value2} others liked this | - |
| `momentsLikeFailed` | Like failed: {value1} | - |
| `momentsLoadingPosts` | Loading postsâ¦ | - |
| `momentsMore` | More | - |
| `momentsNewPostsCount` | {value1} new posts | - |
| `momentsNoChannelContent` | No channel content yet | Channel / ChannelSettings / ChannelMembers |
| `momentsNoComments` | No comments yet | CommentsTitle / Comments |
| `momentsNoFriendPosts` | No posts from friends yet | Contacts / AddContact / AttachContact |
| `momentsNoPostableChannels` | No channels available to post to | Channel / ChannelSettings / ChannelMembers |
| `momentsNoPostsFound` | No posts found | - |
| `momentsNoSearchableChannels` | No searchable channels | Channel / ChannelSettings / ChannelMembers |
| `momentsNotifySubscribers` | Notify subscribers | Notifications / GroupNotifications |
| `momentsOpenOriginalMessage` | Open original message | - |
| `momentsPickPhotoFailed` | Could not select photo | Select / SelectChat / SelectContact; AttachPhoto / SharedPhotosAndVideos |
| `momentsPostAction` | Post | - |
| `momentsPostedTo` | Posted to {value1} | - |
| `momentsPostFailed` | Post failed: {value1} | - |
| `momentsPublishTo` | Post to | - |
| `momentsReplied` | Replied | - |
| `momentsReplyFailed` | Reply failed: {value1} | RepliesTitle / Replies |
| `momentsReplyPrefix` | Reply to {value1}:  | RepliesTitle / Replies |
| `momentsReplyToPlaceholder` | Reply to {value1}â¦ | RepliesTitle / Replies |
| `momentsReplyToUser` | Reply to {value1} | RepliesTitle / Replies |
| `momentsReplyToUserPlaceholder` | Reply to {value1}... | RepliesTitle / Replies |
| `momentsReplyUnavailable` | Replies are not available for this post | RepliesTitle / Replies |
| `momentsSearchChannelPosts` | Search channel posts | Search / SearchMessages / NoResult; Channel / ChannelSettings / ChannelMembers |
| `momentsSearching` | Searchingâ¦ | - |
| `momentsSearchJoinedChannelPosts` | Search posts from joined channels | Search / SearchMessages / NoResult; Channel / ChannelSettings / ChannelMembers |
| `momentsSelectChannel` | Select channel | Select / SelectChat / SelectContact; Channel / ChannelSettings / ChannelMembers |
| `momentsSending` | Sending | SendMessage |
| `momentsShareSomethingPlaceholder` | Share something new... | ShareFile / ShareLink / SharedMedia |
| `momentsStories` | Stories | Story |
| `momentsUnknown` | Unknown | - |
| `momentsUserLiked` | {value1} liked this | - |
| `musicPlayerAddedToPlaylist` | Added to playlist | AttachMusic / SharedMusicTab; Add |
| `musicPlayerAddToPlaylist` | Playlist | AttachMusic / SharedMusicTab; Add |
| `musicPlayerAlreadyInPlaylist` | Already in the playlist | AttachMusic / SharedMusicTab |
| `musicPlayerClose` | Close | AttachMusic / SharedMusicTab |
| `musicPlayerEmptyPlaylist` | No music in the playlist yet | AttachMusic / SharedMusicTab |
| `musicPlayerQueueTitleWithCount` | Play queue ({value1}) | AttachMusic / SharedMusicTab; Play / Pause / Next |
| `musicPlayerRemovedFromPlaylist` | Removed from playlist | AttachMusic / SharedMusicTab |
| `musicPlayerShowPlaylist` | Playlist | AttachMusic / SharedMusicTab |
| `myAlbumNoPhotos` | No photos yet | AttachPhoto / SharedPhotosAndVideos |
| `netemoMusicLabel` | Netemo music | AttachMusic / SharedMusicTab |
| `notificationGroupMessages` | Group messages | NewGroup / GroupMembers / Groups; Notifications / GroupNotifications |
| `notificationPreview` | Notification preview | Notifications / GroupNotifications |
| `notificationPrivateMessages` | Private messages | Notifications / GroupNotifications |
| `notificationSound` | Sound | Notifications / GroupNotifications |
| `notificationTitle` | Message notifications | Notifications / GroupNotifications |
| `pollComposerAddOption` | Add option | Poll; Add |
| `pollComposerCreatePollTitle` | Create poll | Poll |
| `pollComposerOptionLabel` | Option {value1} | Poll |
| `pollComposerQuestionRequired` | Enter a question | Poll |
| `pollComposerSingleChoiceLimitHint` | Single choice Â· Up to 10 options | Poll |
| `premiumLabel` | Premium | - |
| `privacyBlockedUsersEmpty` | No blocked users | ReportSpamUser / BlockedUsers / Unblock; PrivacySettings / LastSeen / BlockedUsers |
| `privacyDeleteTelegramAccount` | Delete Telegram account | Delete / DeleteChat / DeleteAll / DeleteAllFrom; PrivacySettings / LastSeen / BlockedUsers |
| `privacyDeleteTelegramAccountMessage` | Telegram accounts are managed by Telegram and can be set to delete automatically after a period of inactivity in Telegram settings. To delete sooner, open Telegram's official account deletion page and complete deletion directly with Telegram. | Delete / DeleteChat / DeleteAll / DeleteAllFrom; PrivacySettings / LastSeen / BlockedUsers; Settings |
| `privacyDeleteTelegramAccountOpen` | Open deletion page | Delete / DeleteChat / DeleteAll / DeleteAllFrom; PrivacySettings / LastSeen / BlockedUsers |
| `privacyDeviceApp` | App | PrivacySettings / LastSeen / BlockedUsers; Devices / CurrentSession / OtherSessions |
| `privacyLoginQrAcceptFailed` | Could not approve this login QR code | PrivacySettings / LastSeen / BlockedUsers; Login / Devices |
| `privacyLoginQrAccepted` | Login approved | PrivacySettings / LastSeen / BlockedUsers; Login / Devices |
| `privacyLoginQrInvalid` | This is not a Telegram login QR code | PrivacySettings / LastSeen / BlockedUsers; Login / Devices |
| `privacyNoOtherDevices` | No other devices are logged in | PrivacySettings / LastSeen / BlockedUsers; Devices / CurrentSession / OtherSessions; Login / Devices |
| `privacyScanLoginQr` | Scan login QR code | PrivacySettings / LastSeen / BlockedUsers; Login / Devices |
| `privacyScanLoginQrSubtitle` | Scan the QR code shown on another Telegram login screen to approve that device. | PrivacySettings / LastSeen / BlockedUsers; Devices / CurrentSession / OtherSessions; Login / Devices |
| `privacySectionTitle` | Privacy | PrivacySettings / LastSeen / BlockedUsers |
| `privacySecuritySectionTitle` | Security | PrivacySettings / LastSeen / BlockedUsers |
| `privacySecurityTitle` | Privacy and security | PrivacySettings / LastSeen / BlockedUsers |
| `privacyTerminateAllOtherSessions` | Terminate all other sessions | PrivacySettings / LastSeen / BlockedUsers; CurrentSession / OtherSessions |
| `privacyTerminateSession` | Terminate | PrivacySettings / LastSeen / BlockedUsers; CurrentSession / OtherSessions |
| `privacyTerminateSessionMessage` | Terminate {value1}? | PrivacySettings / LastSeen / BlockedUsers; CurrentSession / OtherSessions |
| `privacyTerminateSessionQuestion` | Terminate this session? | PrivacySettings / LastSeen / BlockedUsers; CurrentSession / OtherSessions |
| `profileDayMode` | Day | - |
| `profileDetailAddFriendDone` | Friend added | Contacts / AddContact / AttachContact; Done; Add |
| `profileDetailAddFriendFailed` | Could not add friend | Contacts / AddContact / AttachContact; Add |
| `profileDetailAudioVideoCall` | Audio/video call | AttachVideo / Videos; AttachMusic / AttachAudio; Call / VideoCall |
| `profileDetailBirthday` | Birthday | - |
| `profileDetailCardLinkCopied` | Profile card link copied | Copy; SharedLinksTab / ShareLink |
| `profileDetailFeaturedPhotos` | Featured photos | AttachPhoto / SharedPhotosAndVideos |
| `profileDetailLocation` | Location | AttachLocation |
| `profileDetailMonthDayDate` | {value1}/{value2} | - |
| `profileDetailYearMonthDate` | {value1}/{value2} | - |
| `profileNightMode` | Night | - |
| `profileLogOutAccountConfirm` | This will revoke the Telegram session for {value1}, remove its local data, and delete its saved Keychain backup. | Delete / DeleteChat / DeleteAll / DeleteAllFrom; CurrentSession / OtherSessions; Save |
| `profileRemoveAccount` | Remove account | Delete / DeleteChat / DeleteAll / DeleteAllFrom |
| `profileRemoveAccountConfirm` | {value1} will be removed from this device. The Telegram session stays active on Telegram and can be restored from a saved backup. | Delete / DeleteChat / DeleteAll / DeleteAllFrom; Devices / CurrentSession / OtherSessions; CurrentSession / OtherSessions; Save |
| `proxyAddFailed` | Failed to add proxy | Add |
| `proxyAddProxy` | Add proxy | Add |
| `proxyDeleteProxy` | Delete proxy | Delete / DeleteChat / DeleteAll / DeleteAllFrom |
| `proxyDescription` | The proxy is only used to connect to Telegram and may slow down your connection. | - |
| `proxyDisabled` | No proxy | - |
| `proxyHostOrIp` | Host or IP | - |
| `proxyOptional` | Optional | - |
| `proxyPassword` | Password | TwoStepVerification / Password |
| `proxyPort` | Port | - |
| `proxySecret` | Secret | - |
| `proxyServer` | Server | - |
| `proxyTitle` | Proxy | - |
| `qrCodeGroupTitle` | Group QR code | NewGroup / GroupMembers / Groups |
| `qrCodeMineTitle` | My QR code | - |
| `qrCodeNoGroupQrCode` | No group QR code yet | NewGroup / GroupMembers / Groups |
| `qrCodeScanToAddFriend` | Scan the QR code above to add me as a friend | Contacts / AddContact / AttachContact; Add |
| `qrCodeScanToJoinGroup` | Scan the QR code above to join the group chat | NewGroup / GroupMembers / Groups |
| `richTextComposerAddColumn` | Add column | Add |
| `richTextComposerAddRow` | Add row | Add |
| `richTextComposerContentPlaceholder` | Enter rich text | - |
| `richTextComposerFormatBold` | Bold | - |
| `richTextComposerFormatBoldMark` | B | - |
| `richTextComposerFormatCode` | Code | - |
| `richTextComposerFormatItalic` | Italic | - |
| `richTextComposerFormatItalicMark` | I | - |
| `richTextComposerFormatSpoiler` | Spoiler | - |
| `richTextComposerFormatStrikethrough` | Strikethrough | - |
| `richTextComposerFormatStrikethroughMark` | S | - |
| `richTextComposerFormatUnderline` | Underline | - |
| `richTextComposerFormatUnderlineMark` | U | - |
| `richTextComposerInsertTable` | Table | - |
| `richTextComposerPhotoVideo` | Photo/video | AttachPhoto / SharedPhotosAndVideos; AttachVideo / Videos |
| `richTextComposerRemoveColumn` | Remove column | Delete / DeleteChat / DeleteAll / DeleteAllFrom |
| `richTextComposerRemoveRow` | Remove row | Delete / DeleteChat / DeleteAll / DeleteAllFrom |
| `richTextComposerRemoveTable` | Remove table | Delete / DeleteChat / DeleteAll / DeleteAllFrom |
| `settingsAboutMithka` | About Mithka | Settings |
| `settingsLogOut` | Log Out | Settings |
| `sharedMediaCacheDeleted` | Local cache deleted | ShareFile / ShareLink / SharedMedia; ClearTelegramCache |
| `sharedMediaCacheDeleteFailed` | Couldn't delete cache | Delete / DeleteChat / DeleteAll / DeleteAllFrom; ShareFile / ShareLink / SharedMedia; ClearTelegramCache |
| `sharedMediaChatFiles` | Chat Files | ShareFile / ShareLink / SharedMedia; AttachDocument / SharedFilesTab |
| `sharedMediaDeleteLocalCache` | Delete local cache | Delete / DeleteChat / DeleteAll / DeleteAllFrom; ShareFile / ShareLink / SharedMedia; ClearTelegramCache |
| `sharedMediaDownloadedSize` | Downloaded {value1} | ShareFile / ShareLink / SharedMedia; Download / Downloaded |
| `sharedMediaDownloadProgress` | Downloaded {value1} of {value2} | ShareFile / ShareLink / SharedMedia; Download / Downloaded |
| `sharedMediaFromSource` | From {value1} | ShareFile / ShareLink / SharedMedia |
| `sharedMediaNotDownloadedSize` | Not downloaded Â· {value1} | ShareFile / ShareLink / SharedMedia; Download / Downloaded |
| `sharedMediaSearchFilesHint` | Search file names, chats, or senders | Search / SearchMessages / NoResult; ShareFile / ShareLink / SharedMedia; AttachDocument / SharedFilesTab |
| `sharedMediaSearchVideosHint` | Search videos, groups, names, or #hashtags | Search / SearchMessages / NoResult; ShareFile / ShareLink / SharedMedia; NewGroup / GroupMembers / Groups; AttachVideo / Videos |
| `sharedMediaVideoTitleWithDate` | {value1} video | ShareFile / ShareLink / SharedMedia; AttachVideo / Videos |
| `startButton` | Start | - |
| `stickerSetDetailActionFailed` | Action failed | AttachSticker |
| `stickerSetDetailAddSuccess` | Sticker added | AttachSticker; Add |
| `stickerSetDetailRemoved` | Sticker removed | AttachSticker |
| `stickerSetDetailStickerCount` | {value1} stickers | AttachSticker |
| `stickerSetDetailTitle` | Sticker Details | AttachSticker |
| `stickerStoreRecent` | Recent | AttachSticker |
| `stickerViewerInCollection` | Added | AttachSticker; Add |
| `storyLoadFailed` | Failed to load story | Story |
| `storyUnsupported` | Unsupported story | Story |
| `tabFriendMoments` | Friends' Moments | Contacts / AddContact / AttachContact |
| `tabMoments` | Moments | - |
| `tabSelectChannelContent` | Select channel content | Select / SelectChat / SelectContact; Channel / ChannelSettings / ChannelMembers |
| `tabSelectContact` | Select contact | Select / SelectChat / SelectContact; Contacts / AddContact / AttachContact |
| `tdMessageBoostedGroup` | Boosted this group | NewGroup / GroupMembers / Groups |
| `tdMessageDaysDuration` | {value1} days | - |
| `tdMessageFileWithName` | [File] {value1} | AttachDocument / SharedFilesTab |
| `tdMessageGroupNameChanged` | Group name changed to {value1} | NewGroup / GroupMembers / Groups |
| `tdMessageHoursDuration` | {value1} hours | - |
| `tdMessageLastSeenMonthDay` | Last seen {value1}/{value2} | LastSeen |
| `tdMessageLastSeenTodayTime` | Last seen today at {value1}:{value2} | LastSeen |
| `tdMessageLastSeenUnknown` | Last seen unknown | LastSeen |
| `tdMessageLastSeenYearMonthDay` | Last seen {value1}/{value2}/{value3} | LastSeen |
| `tdMessageLastSeenYesterdayTime` | Last seen yesterday at {value1}:{value2} | LastSeen |
| `tdMessageMinutesDuration` | {value1} minutes | - |
| `tdMessagePaidMessagePriceChanged` | Message price changed to {value1} Stars | - |
| `tdMessagePaidMessagesDisabled` | Paid messages turned off | - |
| `tdMessagePaidMessageSettingsChanged` | [Paid message settings changed] | Settings |
| `tdMessageSecondsDuration` | {value1} seconds | - |
| `tdMessageStickerWithEmoji` | [Sticker {value1}] | AttachSticker; Emoji |
| `themeApplePingFangFamily` | Apple / PingFang | Theme / ColorTheme |
| `themeGroupAssistantSecondPageFirst` | First on second screen | NewGroup / GroupMembers / Groups; Theme / ColorTheme |
| `themeGroupAssistantSortByTime` | Sort by time | NewGroup / GroupMembers / Groups; Theme / ColorTheme |
| `themeGroupAssistantTopCollapsed` | Top collapsed | NewGroup / GroupMembers / Groups; Theme / ColorTheme |
| `themeModeDark` | Dark | Theme / ColorTheme |
| `themeModeLight` | Light | Theme / ColorTheme |
| `themePingFangHongKong` | PingFang Hong Kong [HK] | Theme / ColorTheme |
| `themePingFangSimplifiedChinese` | PingFang Simplified Chinese [CN] | Theme / ColorTheme |
| `themePingFangTraditionalChinese` | PingFang Traditional Chinese [TW] | Theme / ColorTheme |
| `themeSystemMonospace` | System monospace | Theme / ColorTheme |
| `themeUnreadChatCount` | Unread chats | Theme / ColorTheme |
| `themeUnreadCountCapAt99` | Show 99+ above 99 | Theme / ColorTheme |
| `themeUnreadCountShowActual` | Show actual count above 99 | Theme / ColorTheme |
| `themeUnreadMessageCount` | Unread messages | Theme / ColorTheme |
| `topicChatAwaitingYourPost` | Waiting for your post | Topics / ForumTopic |
| `topicChatBeKindPrompt` | Be kind | Topics / ForumTopic |
| `topicChatBrowseCount` | {value1} views | Topics / ForumTopic |
| `topicChatChannelNumber` | Channel No. {value1} | Channel / ChannelSettings / ChannelMembers; Topics / ForumTopic |
| `topicChatComposerPlaceholder` | Share a thought, caption, or link | ShareFile / ShareLink / SharedMedia; SharedLinksTab / ShareLink; Topics / ForumTopic |
| `topicChatGroupChatTitle` | Topic Group Chat | NewGroup / GroupMembers / Groups; Topics / ForumTopic |
| `topicChatLeaveChannelConfirm` | Leaving "{value1}" will delete this topic channel. Continue? | Delete / DeleteChat / DeleteAll / DeleteAllFrom; Channel / ChannelSettings / ChannelMembers; Topics / ForumTopic |
| `topicChatLeaveChannelFailed` | Failed to leave channel | Channel / ChannelSettings / ChannelMembers; Topics / ForumTopic |
| `topicChatLikeCommentSummary` | {value1} likes Â· {value2} comments | CommentsTitle / Comments; Topics / ForumTopic |
| `topicChatMemberCount` | {value1} members | Members / GroupMembers / ChannelMembers; Topics / ForumTopic |
| `topicChatMostRelevant` | Most Relevant | Topics / ForumTopic |
| `topicChatMuteFailed` | Failed to mute notifications | Notifications / GroupNotifications; MuteNotifications / UnmuteNotifications; Topics / ForumTopic |
| `topicChatMuteMessagesToggle` | Mute Messages | MuteNotifications / UnmuteNotifications; Topics / ForumTopic |
| `topicChatMyProfile` | My Profile | Topics / ForumTopic |
| `topicChatNoMoreContent` | No more content | Topics / ForumTopic |
| `topicChatPinnedPrefix` | Pinned \|  | PinMessage / PinToTop / PinnedMessages; Topics / ForumTopic |
| `topicChatSelectSection` | Select Section | Select / SelectChat / SelectContact; Topics / ForumTopic |
| `topicChatSelectTime` | Select Time | Select / SelectChat / SelectContact; Topics / ForumTopic |
| `topicChatSetPinnedFailed` | Failed to pin | PinMessage / PinToTop / PinnedMessages; Topics / ForumTopic |
| `topicChatTopicCount` | {value1} topics | Topics / ForumTopic |
| `topicPostContentActionFailed` | Action failed | Topics / ForumTopic |
| `topicPostContentCopied` | Copied | Copy; Topics / ForumTopic |
| `topicPostContentCopiedQuery` | Query copied | Copy; Topics / ForumTopic |
| `translationInternalNoExternalApi` | Internal translation does not use an external API | TranslateMessage |
| `translationLibreTranslateNoResult` | LibreTranslate returned no translation | TranslateMessage |
| `translationLibreTranslateUrlRequired` | Set the LibreTranslate URL first | TranslateMessage; SharedLinksTab / ShareLink |
| `translationLingvaNoResult` | Lingva returned no translation | TranslateMessage |
| `translationMlKitLocal` | ML Kit (local) | TranslateMessage |
| `translationMyMemoryNoResult` | MyMemory returned no translation | TranslateMessage |
| `translationNativeCancelledOrTimedOut` | Native translation was canceled or timed out | TranslateMessage |
| `translationNativeNoExternalApi` | Native translation does not use an external API | TranslateMessage |
| `translationNativeNoResult` | Native translation returned no translation | TranslateMessage |
| `translationServiceInvalidResponse` | Invalid response format from translation service | TranslateMessage |
| `translationServiceReturnedStatus` | Translation service returned {value1} | TranslateMessage |
| `translationServiceUrlInvalid` | Invalid translation service URL | TranslateMessage; SharedLinksTab / ShareLink |
| `translationSettingsService` | Translation Service | TranslateMessage; Settings |
| `translationSettingsTargetLanguage` | Target Language | TranslateMessage; Settings; Language / LanguageName |
| `translationSettingsTitle` | Message Translation | TranslateMessage; Settings |
| `translationSystem` | System Translation | TranslateMessage |
| `translationTelegram` | Telegram Translation | TranslateMessage |
| `updateAction` | Update | - |
| `updateLater` | Later | - |
| `updateNewVersionFound` | New Version Available | - |
| `updateVersionPrompt` | Current version: {value1}. Latest: {value2}. Go download the update? | Download / Downloaded |
| `videoPlayerCachedLocally` | Video cached locally | AttachVideo / Videos; ClearTelegramCache |
| `videoPlayerCannotPlay` | Cannot play video | AttachVideo / Videos; Play / Pause / Next |
| `videoPlayerForwardUnsupported` | This video cannot be forwarded | Forward / ForwardTo / ShareSendTo; AttachVideo / Videos |
| `videoPlayerFullscreen` | Fullscreen | AttachVideo / Videos |
| `videoPlayerLoadFailed` | Failed to load video | AttachVideo / Videos |
| `videoPlayerLoading` | Loading video | AttachVideo / Videos |
| `videoPlayerPictureInPictureFailed` | Picture in Picture failed to start | AttachVideo / Videos |
| `videoPlayerPictureInPicture` | Picture in Picture | AttachVideo / Videos |
| `videoPlayerPlaybackSpeed` | Playback Speed | AttachVideo / Videos |
| `videoPlayerSplitScreen` | Split Screen | AttachVideo / Videos |
| `videoPlayerStreamingWhileDownloading` | Streaming while downloading | AttachVideo / Videos |
| `videoPlayerToggleDisplayMode` | Switch display mode | AttachVideo / Videos |
| `videoPlayerWaitingForFile` | Waiting for video file | AttachVideo / Videos; AttachDocument / SharedFilesTab |
| `vipBadgeLabel` | VIP | - |
