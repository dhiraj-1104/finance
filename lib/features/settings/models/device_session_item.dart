class DeviceSessionItem {
  final String id;
  final String title;
  final String lastActive;
  final String userAgent;
  final bool isDesktop;
  final bool isCurrent;

  const DeviceSessionItem({
    required this.id,
    required this.title,
    required this.lastActive,
    required this.userAgent,
    this.isDesktop = true,
    this.isCurrent = false,
  });

  static List<DeviceSessionItem> defaultSessions() {
    return [
      const DeviceSessionItem(
        id: 'session_1',
        title: 'Other Device',
        lastActive: 'September 11, 2026 12:43:34 PM',
        userAgent: 'Windows 10 (Chrome 152.0.0.0)',
        isDesktop: true,
        isCurrent: false,
      ),
      const DeviceSessionItem(
        id: 'session_2',
        title: 'Other Device',
        lastActive: 'September 11, 2026 12:32:31 PM',
        userAgent: 'Windows 10 (Firefox 155.0)',
        isDesktop: true,
        isCurrent: false,
      ),
      const DeviceSessionItem(
        id: 'session_3',
        title: 'Other Device',
        lastActive: 'September 11, 2026 12:27:33 PM',
        userAgent: 'Linux (Edge 151.0.0.0)',
        isDesktop: true,
        isCurrent: false,
      ),
      const DeviceSessionItem(
        id: 'session_4',
        title: 'Other Device',
        lastActive: 'September 11, 2026 12:23:56 PM',
        userAgent: 'Windows 10 (Chrome 152.0.0.0)',
        isDesktop: true,
        isCurrent: false,
      ),
      const DeviceSessionItem(
        id: 'session_5',
        title: 'Other Device',
        lastActive: 'September 11, 2026 12:07:14 PM',
        userAgent: 'Windows 10 (Firefox 155.0)',
        isDesktop: true,
        isCurrent: false,
      ),
      const DeviceSessionItem(
        id: 'session_6',
        title: 'Other Device',
        lastActive: 'September 11, 2026 11:53:25 AM',
        userAgent: 'Macintosh (Safari 26.6.2)',
        isDesktop: true,
        isCurrent: false,
      ),
      const DeviceSessionItem(
        id: 'session_7',
        title: 'Current',
        lastActive: 'September 11, 2026 11:42:17 AM',
        userAgent: 'iPhone (Mobile Safari 18.5)',
        isDesktop: false,
        isCurrent: true,
      ),
      const DeviceSessionItem(
        id: 'session_8',
        title: 'Other Device',
        lastActive: 'September 11, 2026 11:38:47 AM',
        userAgent: 'Windows 10 (Chrome 117.0.0.0)',
        isDesktop: true,
        isCurrent: false,
      ),
      const DeviceSessionItem(
        id: 'session_9',
        title: 'Other Device',
        lastActive: 'September 11, 2026 08:21:23 AM',
        userAgent: 'iPhone (WeChat 8.0.76)',
        isDesktop: false,
        isCurrent: false,
      ),
      const DeviceSessionItem(
        id: 'session_10',
        title: 'Other Device',
        lastActive: 'September 11, 2026 08:01:08 AM',
        userAgent: 'Macintosh (Chrome 125.0.0.0)',
        isDesktop: true,
        isCurrent: false,
      ),
      const DeviceSessionItem(
        id: 'session_11',
        title: 'Other Device',
        lastActive: 'September 11, 2026 07:06:28 AM',
        userAgent: 'Windows 10 (Edge 152.0.0.0)',
        isDesktop: true,
        isCurrent: false,
      ),
      const DeviceSessionItem(
        id: 'session_12',
        title: 'Other Device',
        lastActive: 'September 11, 2026 06:21:11 AM',
        userAgent: 'Macintosh (Safari 26.6.2)',
        isDesktop: true,
        isCurrent: false,
      ),
    ];
  }
}
