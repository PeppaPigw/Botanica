// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Botanica';

  @override
  String get appTagline => '你的私人植物养护伙伴 — 宁静、精美、用心。';

  @override
  String get gardenNoScheduleYet => '暂无养护计划';

  @override
  String get commonContinue => '继续';

  @override
  String get commonSkip => '跳过';

  @override
  String get commonStart => '开始';

  @override
  String get commonDone => '完成';

  @override
  String get commonOverdue => '已逾期';

  @override
  String get commonUndo => '撤销';

  @override
  String get commonCancel => '取消';

  @override
  String get commonClear => '清除';

  @override
  String get commonSave => '保存';

  @override
  String get commonClose => '关闭';

  @override
  String get commonShow => '显示';

  @override
  String get commonHide => '隐藏';

  @override
  String get commonLater => '稍后';

  @override
  String get commonSearch => '搜索';

  @override
  String get commonEdit => '编辑';

  @override
  String get commonAdd => '添加';

  @override
  String get commonSettings => '设置';

  @override
  String get commonUnits => '单位';

  @override
  String get commonLanguage => '语言';

  @override
  String get commonAbout => '关于';

  @override
  String get commonTryAgain => '重试';

  @override
  String get commonErrorTryAgain => '出了点问题，请重试。';

  @override
  String get commonComingSoon => '即将推出';

  @override
  String get commonLoading => '加载中…';

  @override
  String get commonViewAll => '查看全部';

  @override
  String get commonWhy => '为什么？';

  @override
  String get commonIdeal => '理想';

  @override
  String get commonTolerates => '耐受';

  @override
  String get commonSoil => '土壤';

  @override
  String get commonSoilPh => '土壤酸碱度';

  @override
  String get commonWhen => '时间';

  @override
  String get commonHow => '方法';

  @override
  String get commonPestsAndDiseases => '虫害与病害';

  @override
  String get commonPrevention => '预防';

  @override
  String get commonHeatwave => '热浪';

  @override
  String get commonFrost => '霜冻';

  @override
  String get commonStorm => '风暴';

  @override
  String get commonHeavyRain => '暴雨';

  @override
  String get commonClimateHotDry => '炎热 / 干燥';

  @override
  String get commonClimateCoolWet => '凉爽 / 潮湿';

  @override
  String get commonClimateStrategies => '气候策略';

  @override
  String get resourcesTitle => '资源';

  @override
  String get resourceWikipedia => '维基百科';

  @override
  String get resourceYouTube => 'YouTube';

  @override
  String get resourceBaiduBaike => '百度百科';

  @override
  String get resourceBilibili => '哔哩哔哩';

  @override
  String get resourceGbif => 'GBIF';

  @override
  String get resourceCareGuide => '养护指南';

  @override
  String get resourceCopyLink => '复制链接';

  @override
  String get resourceLinkCopied => '已复制链接';

  @override
  String get aiNoteCopied => '笔记已复制';

  @override
  String get aiNoteCopyAction => '复制笔记';

  @override
  String get stateLoadFailedTitle => '无法加载';

  @override
  String get stateLoadFailedBody => '请检查网络后重试。';

  @override
  String get stateNotAvailableTitle => '暂不可用';

  @override
  String get stateNotAvailableBody => '该内容暂时不可用。';

  @override
  String get navGarden => '花园';

  @override
  String get navCalendar => '日历';

  @override
  String get navDiscover => '发现';

  @override
  String get navDaily => '每日';

  @override
  String get navProfile => '我的';

  @override
  String get calendarTitle => '日历';

  @override
  String get calendarFilterAll => '全部';

  @override
  String get calendarFilterOther => '其他';

  @override
  String get calendarSectionConsistency => '月度一致性';

  @override
  String get calendarPrevMonth => '上个月';

  @override
  String get calendarNextMonth => '下个月';

  @override
  String get calendarSectionHistory => '养护记录';

  @override
  String get calendarWeekAheadTitle => '未来一周';

  @override
  String calendarWeekAheadCount(int count) {
    return '$count 项任务';
  }

  @override
  String get calendarNoEvents => '这一天暂无记录。';

  @override
  String get splashTagline => '宁静养护，优雅整理。';

  @override
  String get onboardingTitle1 => '你的花园，优雅有序';

  @override
  String get onboardingBody1 => '记录植物、建立照片时间轴、随手备注，不再杂乱。';

  @override
  String get onboardingTitle2 => '智能养护，随环境变化';

  @override
  String get onboardingBody2 => '湿度、温度、季节——Botanica 会解释为什么计划会调整。';

  @override
  String get onboardingTitle3 => '每日花语仪式';

  @override
  String get onboardingBody3 => '温柔的每日卡片：寓意、基础养护，以及 60 秒的观赏提示。';

  @override
  String get onboardingCta => '开始使用 Botanica';

  @override
  String get permissionsTitle => '设置你需要的权限';

  @override
  String get permissionsSubtitle => '可一次性开启，也可在使用功能时再开启。';

  @override
  String get permNotificationsTitle => '通知提醒';

  @override
  String get permNotificationsBody => '不错过浇水等养护。';

  @override
  String get notificationsSoftAskTitle => '不错过浇水日';

  @override
  String get notificationsSoftAskBody =>
      'Botanica 会在你偏好的时间温和提醒，让每株植物在叶片低垂前得到照料。';

  @override
  String get permLocationTitle => '位置';

  @override
  String get permLocationBody => '让养护根据气候自动调整。';

  @override
  String get permCameraTitle => '相机与相册';

  @override
  String get permCameraBody => '用于生长记录与植物识别。';

  @override
  String get permLocationServicesOff => '定位服务已关闭。';

  @override
  String get permStatusEnabled => '已开启';

  @override
  String get permStatusNotEnabled => '未开启';

  @override
  String get permStatusLimited => '受限';

  @override
  String get permStatusProvisional => '临时';

  @override
  String get permStatusRestricted => '受限制';

  @override
  String get permStatusBlocked => '已阻止';

  @override
  String get permActionEnable => '开启';

  @override
  String get permActionOpenSettings => '打开设置';

  @override
  String get permissionsEnableAll => '现在全部开启';

  @override
  String get permissionsNotNow => '暂不';

  @override
  String get permissionsPrivacyNote => 'Botanica 只在需要时才请求权限，你可以在「我的」中随时修改。';

  @override
  String get gardenTitle => '花园';

  @override
  String get gardenTodayCardTitle => '今日';

  @override
  String get gardenGreetingMorning => '早上好';

  @override
  String get gardenGreetingAfternoon => '下午好';

  @override
  String get gardenGreetingEvening => '晚上好';

  @override
  String get gardenLoadError => '加载植物失败。';

  @override
  String gardenTasksDueToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个待办',
      zero: '暂无待办',
    );
    return '$_temp0';
  }

  @override
  String get gardenAllCaughtUp => '全部完成！你的植物很开心。';

  @override
  String allDoneQuietRunway(int days) {
    return '未来$days天没有待办';
  }

  @override
  String allDoneTomorrowPreview(int count, String plants) {
    return '明天 · $plants有$count项任务';
  }

  @override
  String get gardenVacationBanner => '假期模式 — 提醒已暂停';

  @override
  String get gardenWeeklySummaryTitle => '本周';

  @override
  String gardenWeeklyCareActions(int count) {
    return '$count 次护理';
  }

  @override
  String gardenWeeklyWatered(int count) {
    return '浇水 $count 次';
  }

  @override
  String gardenWeeklyFertilized(int count) {
    return '施肥 $count 次';
  }

  @override
  String gardenCareStreakChip(int days) {
    return '连续护理$days天';
  }

  @override
  String gardenStreakAtRisk(int days) {
    return '你的$days天连续记录今天就要断了——快去照顾一棵植物吧！';
  }

  @override
  String gardenWeatherChip(
      String condition, int temp, String unit, int humidity) {
    return '$condition · $temp°$unit · $humidity%';
  }

  @override
  String get weatherClear => '晴朗';

  @override
  String get weatherPartlyCloudy => '多云';

  @override
  String get weatherCloudy => '阴';

  @override
  String get weatherFog => '雾';

  @override
  String get weatherDrizzle => '毛毛雨';

  @override
  String get weatherRain => '雨';

  @override
  String get weatherSnow => '雪';

  @override
  String get weatherThunder => '雷暴';

  @override
  String get weatherUnknown => '天气';

  @override
  String get weatherTipRainy => '外面下雨了——今天跳过户外植物浇水';

  @override
  String get weatherTipStormy => '暴风雨天气——将敏感植物移至室内';

  @override
  String get weatherTipExtremeHeat => '极端高温——检查土壤湿度并喷雾叶片';

  @override
  String get weatherTipHotSunny => '炎热晴天——清晨或傍晚浇水';

  @override
  String get weatherTipNearFreezing => '接近冰点——保护怕冻植物';

  @override
  String get weatherTipSnow => '预计有雪——将户外花盆移至遮蔽处';

  @override
  String get weatherTipCool => '凉爽天气——减少浇水频率';

  @override
  String get weatherTipLowHumidity => '空气干燥——给热带植物喷雾或将它们聚在一起';

  @override
  String get weatherTipHighHumidity => '湿度高——暂停喷雾，注意真菌问题';

  @override
  String get seasonalTipSpring => '春天来了——是施肥和换盆的好时机';

  @override
  String get seasonalTipSummer => '夏季炎热，大多数植物需要更频繁浇水';

  @override
  String get seasonalTipAutumn => '秋季——植物生长放缓，减少施肥';

  @override
  String get seasonalTipWinter => '冬季——大多数植物需要更少的水和肥料';

  @override
  String get gardenQuickWatered => '已浇水';

  @override
  String get gardenQuickSnooze => '稍后提醒';

  @override
  String get gardenQuickLogCare => '记录养护';

  @override
  String get gardenQuickLogDone => '已记录！';

  @override
  String get gardenViewDetails => '查看详情';

  @override
  String get tasksSnoozeOneHour => '1小时';

  @override
  String get tasksSnoozeThreeHours => '3小时';

  @override
  String get tasksSnoozeTomorrow => '明天';

  @override
  String get tasksSnoozeTomorrowMorning => '明天上午';

  @override
  String get tasksSnoozeWeekend => '这个周末';

  @override
  String get tasksSnoozeCustomTime => '自定义时间';

  @override
  String get gardenQuickAddPlant => '添加植物';

  @override
  String get gardenRoomsTitle => '房间';

  @override
  String get gardenRoomsAll => '全部房间';

  @override
  String get gardenToggleCardMode => '切换卡片模式';

  @override
  String get gardenToggleViewMode => '切换视图模式';

  @override
  String gardenRoomPlantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 株植物',
      one: '1 株植物',
    );
    return '$_temp0';
  }

  @override
  String profilePlantsInGarden(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '花园中有 $count 株植物',
      one: '花园中有 1 株植物',
    );
    return '$_temp0';
  }

  @override
  String get discoverInYourGarden => '已在花园中';

  @override
  String get gardenRoomsWaterAll => '全部浇水';

  @override
  String get gardenRoomsSnoozeAll => '全部延后';

  @override
  String gardenRoomsWateredCount(int count) {
    return '已为 $count 株植物浇水';
  }

  @override
  String gardenRoomsSnoozedCount(int count) {
    return '已延后 $count 个任务';
  }

  @override
  String get gardenEmptyTitle => '开始你的花园';

  @override
  String get gardenEmptyBody => '添加第一株植物，获得专属养护计划与每日任务。';

  @override
  String get gardenEmptyCta => '添加第一株植物';

  @override
  String get gardenAddPlantFab => '添加植物';

  @override
  String get addPlantTitle => '添加植物';

  @override
  String get addPlantMethodScan => '扫描';

  @override
  String get addPlantMethodLibrary => '从植物库';

  @override
  String get addPlantMethodManual => '手动填写';

  @override
  String get addPlantScanTitle => '扫描植物';

  @override
  String get addPlantScanBody => '拍摄叶片 + 全株，识别更准确。';

  @override
  String get addPlantScanButton => '开始识别';

  @override
  String get addPlantLibraryTitle => '选择植物';

  @override
  String get addPlantManualTitle => '填写信息';

  @override
  String get addPlantConfirmTitle => '确认信息';

  @override
  String get addPlantFieldNickname => '昵称';

  @override
  String get addPlantFieldRoom => '房间';

  @override
  String get addPlantDefaultRoomLivingRoom => '客厅';

  @override
  String get addPlantDefaultSpeciesUnknown => '未知';

  @override
  String get addPlantFieldEnvironment => '环境';

  @override
  String get addPlantEnvIndoor => '室内';

  @override
  String get addPlantEnvBalcony => '阳台';

  @override
  String get addPlantEnvOutdoor => '户外';

  @override
  String get addPlantReminderTime => '提醒时间';

  @override
  String get addPlantReminderMorning => '早上';

  @override
  String get addPlantReminderEvening => '晚上';

  @override
  String get addPlantReminderCustom => '自定义';

  @override
  String get addPlantSaveButton => '保存到花园';

  @override
  String get plantDetailOverview => '概览';

  @override
  String get plantDetailCare => '养护';

  @override
  String get plantDetailJournal => '记录';

  @override
  String get plantDetailLogs => '日志';

  @override
  String get plantDetailLogsEmptyTitle => '暂无养护日志';

  @override
  String get plantDetailLogsEmptyBody => '完成一次浇水或养护任务后，记录会显示在这里。';

  @override
  String get tasksEmptySoon => '近期暂无任务，做得好！';

  @override
  String get tasksEmptyWatch => '暂无需要关注的任务。植物正在休息。';

  @override
  String get plantDetailWaterNow => '现在浇水';

  @override
  String get plantDetailAddPhoto => '添加照片';

  @override
  String get plantDetailAddNote => '添加备注';

  @override
  String get plantDetailMissingTitle => '植物不可用';

  @override
  String get plantDetailMissingBody => '找不到这株植物，可能已被删除。';

  @override
  String get plantDetailMissingCta => '返回花园';

  @override
  String plantDetailNextWateringInDays(int days) {
    return '距离下次浇水还有 $days 天';
  }

  @override
  String plantDetailCaringForDays(int days) {
    return '已照顾 $days 天';
  }

  @override
  String get plantDetailEnvironmentImpactTitle => '环境影响';

  @override
  String plantDetailEnvironmentImpactBaseAdjusted(int base, int adjusted) {
    return '基础：$base 天 · 调整后：$adjusted 天';
  }

  @override
  String get plantDetailEnvironmentStable => '环境稳定——今天无需调整。';

  @override
  String get plantDetailDrynessLow => '干燥指数低（干得更慢）';

  @override
  String get plantDetailDrynessBalanced => '干燥指数适中';

  @override
  String get plantDetailDrynessHigh => '干燥指数高（干得更快）';

  @override
  String get plantDetailCareWaterBody => '下次浇水由基础间隔计算，并根据湿度、温度与季节进行调整。';

  @override
  String get plantDetailCareLightBody => '对多数室内植物来说，明亮散射光是很好的默认选择。';

  @override
  String get plantDetailCareTempTitle => '温度';

  @override
  String get plantDetailCareTempBody => '避免突然的冷风直吹。稳定的温暖有助于规律生长。';

  @override
  String get plantDetailJournalDesignNote => '这里已设计好对齐取景叠层与对比滑杆；后续可接入相机/相册。';

  @override
  String get plantDetailJournalIntro => '用照片与文字记录成长——这是你的植物日记。';

  @override
  String get journalSectionPhotos => '照片';

  @override
  String get diarySectionTitle => '日记';

  @override
  String get diaryEmptyBody => '还没有文字记录。写一条，记下今天的变化。';

  @override
  String get diaryAddEntryTitle => '新建日记';

  @override
  String get diaryAddEntryHint => '写下你今天观察到的内容…';

  @override
  String get diaryAddEntryButton => '写日记';

  @override
  String get diaryEntryTitle => '日记内容';

  @override
  String get diaryEntrySaved => '已保存到日记。';

  @override
  String get diaryEditEntryTitle => '编辑日记';

  @override
  String get diaryEditConfirmTitle => '保存更改？';

  @override
  String get diaryEditConfirmBody => '用你的修改更新这篇日记。';

  @override
  String get diaryEntryUpdated => '日记已更新。';

  @override
  String get diaryEntryDeleted => '日记已删除。';

  @override
  String get diaryEntryDeleteTitle => '删除日记？';

  @override
  String get diaryEntryDeleteBody => '这会从时间线中移除该日记。删除后可以立即撤销。';

  @override
  String get diaryPromptGrowingWell => '长势不错';

  @override
  String get diaryPromptNewLeaf => '新叶';

  @override
  String get diaryPromptStruggling => '状态吃力';

  @override
  String get diaryPromptRepotted => '已换盆';

  @override
  String get diaryPromptBlooming => '开花了';

  @override
  String get journalEntryActions => '条目操作';

  @override
  String get journalShareCardTitle => '分享卡片';

  @override
  String get journalShareCardText => '由 Botanica 制作';

  @override
  String get journalShareFailed => '分享失败，请重试。';

  @override
  String get journalAddPhotoTitle => '添加照片';

  @override
  String get journalAddPhotoCamera => '相机';

  @override
  String get journalAddPhotoCameraBody => '拍摄新照片，可叠加上一张照片的半透明参考。';

  @override
  String get journalAddPhotoGallery => '相册';

  @override
  String get journalAddPhotoGalleryBody => '从相册选择一张照片。';

  @override
  String get journalCaptureTitle => '拍摄';

  @override
  String get journalCaptureTip => '尽量填满取景框，并对齐上一张以便更好对比。';

  @override
  String get journalFlash => '闪光灯';

  @override
  String get journalCameraPermissionNeeded => '需要相机权限才能拍摄照片。';

  @override
  String get journalPhotosPermissionNeeded => '需要相册权限才能选择照片。';

  @override
  String get journalPhotoSaved => '已保存到记录。';

  @override
  String get journalPhotoDeleted => '照片已删除。';

  @override
  String get journalPhotoDeleteTitle => '删除照片？';

  @override
  String get journalPhotoDeleteBody => '这会从这株植物的记录和本地存储中移除该照片。删除后可以立即撤销。';

  @override
  String get journalEmptyBody => '还没有照片。添加一张开启生长时间轴。';

  @override
  String get journalPhotoTitle => '记录照片';

  @override
  String get journalPhotoNoNote => '无备注';

  @override
  String get journalAddNoteTitle => '添加备注';

  @override
  String get journalAddNoteHint => '可选：新叶、换盆等。';

  @override
  String get journalCompareTitle => '对比';

  @override
  String get journalCompareHint => '左右拖动进行对比。';

  @override
  String get journalPhotoUnavailable => '照片不可用';

  @override
  String get journalOverlayStrength => '叠影强度';

  @override
  String get journalPreviousPhoto => '上一张照片';

  @override
  String get journalLimitedPhotosAccess =>
      '当前为“选中的照片”权限。你可以选择已授权照片，也可以在 iOS 设置中调整访问范围。';

  @override
  String journalPhotoMeta(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get scanTitle => '识别';

  @override
  String get scanTryAgain => '重试';

  @override
  String get scanCaptureTitle => '识别你的植物';

  @override
  String get scanCaptureTip => '同时拍摄叶片与整株，效果更好。';

  @override
  String get scanCameraPermissionNeeded => '需要相机权限才能识别植物。';

  @override
  String get scanCameraPermissionTitle => '相机访问';

  @override
  String get scanCameraPermissionBody => '可以打开相机快速识别；也可以不授权，直接浏览植物库。';

  @override
  String get scanUseCamera => '使用相机';

  @override
  String get scanProcessingBody => '正在识别植物…';

  @override
  String get scanChooseCandidate => '选择匹配项';

  @override
  String get scanRefineTitle => '不确定？进一步筛选结果';

  @override
  String get scanRefineHelper => '回答一个快速问题来缩小结果范围。';

  @override
  String get scanRefineFallbackNote => '这些筛选条件暂时没有完全匹配项——正在显示最接近的结果。';

  @override
  String get scanConfidenceGuide => '置信度仅供参考——添加前请对比外形和养护标签。';

  @override
  String get scanConfidenceStrongLabel => '高置信度';

  @override
  String get scanConfidenceStrongBody => '与拍摄植物看起来非常接近。';

  @override
  String get scanConfidenceLikelyLabel => '中等置信度';

  @override
  String get scanConfidenceLikelyBody => '添加前请对比细节。';

  @override
  String get scanConfidencePossibleLabel => '低置信度——换个角度再试';

  @override
  String get scanConfidencePossibleBody => '这只是最佳猜测——可以再拍一个角度。';

  @override
  String get scanRefineFlowering => '它在开花吗？';

  @override
  String get scanRefineIndoorOutdoor => '室内还是室外？';

  @override
  String get scanRefineSucculent => '多肉类型？';

  @override
  String get scanRefinePetSafe => '宠物友好';

  @override
  String get scanRefineEasy => '易养护';

  @override
  String get scanRefineLowLight => '耐低光';

  @override
  String get scanAddToGarden => '添加到花园';

  @override
  String get scanBrowseLibrary => '改为浏览植物库';

  @override
  String get scanTakingLongerTitle => '耗时比预期更久';

  @override
  String get scanTakingLongerBody => '本次识别未能及时完成。你可以重试，或手动选择植物。';

  @override
  String get scanNoResultTitle => '无法识别这株植物';

  @override
  String get scanNoResultBody => '换个角度拍摄叶片细节，或直接浏览植物库。';

  @override
  String get scanDeterministicNote =>
      '演示模式：离线结果为可重复的占位识别，可后续接入 Kindwise/Gemini。';

  @override
  String get tasksTitle => '任务';

  @override
  String get tasksTabToday => '今日';

  @override
  String get tasksTabSoon => '近期';

  @override
  String get tasksTabWatch => '观察';

  @override
  String get tasksCalendarToggle => '日历';

  @override
  String get tasksSeasonalTipsTitle => '季节护理小贴士';

  @override
  String get tipSpringRepot => '春季：新生长开始且根系拥挤时，考虑换盆。';

  @override
  String get tipSpringFertilize => '春季：开始长新叶后，恢复少量施肥。';

  @override
  String get tipSummerWaterMore => '夏季：高温更易干燥，勤检查土壤湿度。';

  @override
  String get tipSummerShadeOutdoor => '夏季：阳台/室外植物避免正午强光暴晒。';

  @override
  String get tipAutumnReduceWater => '秋季：光照变弱时，适当减少浇水频率。';

  @override
  String get tipAutumnBringIndoor => '秋季：夜间转凉，怕冷植物提前移入室内。';

  @override
  String get tipWinterReduceFertilize => '冬季：生长放缓，减少施肥并降低浇水。';

  @override
  String get tipWinterLowLight => '冬季：尽量靠近窗边或补光，避免徒长。';

  @override
  String tasksSnoozedUntil(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '已延后至 $dateString';
  }

  @override
  String get tasksSkipped => '已跳过';

  @override
  String get discoverTitle => '发现';

  @override
  String get discoverPlantOfTheDay => '今日植物';

  @override
  String get discoverSearchHint => '搜索植物、指南与技巧';

  @override
  String get discoverNoResultsTitle => '未找到匹配结果';

  @override
  String get discoverNoResultsBody => '试试其他名称，或使用学名搜索。';

  @override
  String get discoverSectionCurated => '精选植物';

  @override
  String get discoverSectionLibrary => '植物图鉴';

  @override
  String get discoverSectionGuides => '指南';

  @override
  String get discoverFilters => '筛选';

  @override
  String get discoverFilterPetSafe => '宠物友好';

  @override
  String get discoverFilterDifficulty => '难度';

  @override
  String get discoverFilterLight => '光照';

  @override
  String get discoverTagPetSafe => '宠物友好';

  @override
  String get discoverTagToxic => '有毒';

  @override
  String get discoverGuideWateringTitle => '浇水基础';

  @override
  String get discoverGuideWateringBody => '学会判断土壤湿度，避免过度浇水。';

  @override
  String get discoverGuideSoilTitle => '土壤与排水';

  @override
  String get discoverGuideSoilBody => '为什么疏松透气的介质能减少烂根并促进生长。';

  @override
  String get discoverGuidePestTitle => '虫害检查清单';

  @override
  String get discoverGuidePestBody => '每周 1 次的小流程，及早发现问题。';

  @override
  String get discoverAddFavorite => '添加到收藏';

  @override
  String get discoverRemoveFavorite => '从收藏中移除';

  @override
  String get speciesDetailHistory => '历史';

  @override
  String get speciesDetailHabit => '生长习性';

  @override
  String get speciesDetailCareAtAGlance => '养护速览';

  @override
  String speciesDetailWaterEvery(int days) {
    return '每 $days 天浇水';
  }

  @override
  String speciesDetailFertilizeEvery(int days) {
    return '每 $days 天施肥';
  }

  @override
  String speciesDetailMistEvery(int days) {
    return '每 $days 天喷雾';
  }

  @override
  String get speciesDetailDetails => '详情';

  @override
  String get speciesDetailOrigin => '原产地';

  @override
  String get speciesDetailToxicity => '毒性';

  @override
  String get speciesDetailGrowth => '生长';

  @override
  String get speciesDetailMatureSize => '成熟尺寸';

  @override
  String get speciesDetailSizeHeight => '高度';

  @override
  String get speciesDetailSizeSpread => '冠幅';

  @override
  String get speciesDetailSizeVineLength => '藤长';

  @override
  String speciesDetailRangeCm(int min, int max) {
    return '$min–$max 厘米';
  }

  @override
  String speciesDetailCmValue(int value) {
    return '$value 厘米';
  }

  @override
  String get speciesDetailUnknown => '未知';

  @override
  String get growthRateSlow => '慢';

  @override
  String get growthRateModerate => '中等';

  @override
  String get growthRateFast => '快';

  @override
  String get growthRateUnknown => '未知';

  @override
  String get growthFormUpright => '直立';

  @override
  String get growthFormTrailing => '垂吊';

  @override
  String get growthFormClimbing => '攀援';

  @override
  String get growthFormRosette => '莲座';

  @override
  String get growthFormTreeLike => '木本';

  @override
  String get growthFormClumping => '丛生';

  @override
  String get growthFormEpiphytic => '附生';

  @override
  String get growthFormSucculent => '多肉';

  @override
  String get growthFormFern => '蕨类';

  @override
  String get growthFormOrchid => '兰科';

  @override
  String get growthFormOther => '其他';

  @override
  String get difficultyEasy => '简单';

  @override
  String get difficultyMedium => '中等';

  @override
  String get difficultyHard => '困难';

  @override
  String get lightBrightDirect => '明亮直射光';

  @override
  String get lightBrightIndirect => '明亮散射光';

  @override
  String get lightMediumIndirect => '中等散射光';

  @override
  String get lightLowToBrightIndirect => '弱光到明亮散射光';

  @override
  String get lightLowToBright => '弱光到明亮光';

  @override
  String get dailyTitle => '每日花语';

  @override
  String get dailyReveal => '揭晓';

  @override
  String get dailyRevealHintTap => '点击揭晓';

  @override
  String get dailyRevealHintSlide => '滑动揭晓';

  @override
  String get dailyRevealHintHold => '长按揭晓';

  @override
  String get dailyRevealHintPull => '下拉揭晓';

  @override
  String get dailyRevealHintStamp => '盖章揭晓';

  @override
  String get dailyRevealHintFlip => '翻牌揭晓';

  @override
  String get dailyRevealHintTrace => '描摹揭晓';

  @override
  String get dailyInfoTitle => '关于每日花语';

  @override
  String get dailyInfoIntro => '每日花语是一个每天更新一次的温柔仪式，用来获得灵感与陪伴。';

  @override
  String get dailyInfoModeWesternZodiac => '星座：根据你的生日或手动选择的星座生成。';

  @override
  String get dailyInfoModeTarot => '塔罗：每天发四张牌并选择一张，你的选择将引导今日之花。';

  @override
  String dailyInfoModeAuto(String mode) {
    return '$mode：基于今日日期进行每日抽取，并结合个人信息进行个性化。';
  }

  @override
  String get dailyInfoModeJustFlower => '仅花：最简单的仪式。轻点即可揭晓一朵为你个性化的今日花。';

  @override
  String dailyInfoHowToReveal(String hint) {
    return '如何揭晓：$hint';
  }

  @override
  String get dailyInfoChangeMode => '更改模式';

  @override
  String get dailySave => '保存';

  @override
  String get dailyShare => '分享';

  @override
  String get dailyCareToday => '今日养护';

  @override
  String get dailyHowToAppreciate => '今日观赏方式';

  @override
  String get dailyAiNoteTitle => 'Botanica 小笺';

  @override
  String get plantCareAiTipTitle => '今日养护提示';

  @override
  String get dailyModeMissingTitle => '选择每日模式';

  @override
  String get dailyModeMissingBody => '选择一种传统（塔罗、黄历、符文…），Botanica 会为你生成专属的每日花语。';

  @override
  String get dailyModeMissingCta => '选择模式';

  @override
  String get dailyTarotNotDrawn => '今日抽牌';

  @override
  String get dailyTarotDrawTitle => '塔罗抽牌';

  @override
  String get dailyTarotDrawBody => '发四张牌，选一张 — 然后揭晓今日之花。';

  @override
  String get dailyTarotDrawCta => '发 4 张牌';

  @override
  String get dailyTarotCardLabel => '选择';

  @override
  String get dailyDeterministicNote =>
      '每日花语是确定性的：同一天 + 语言 + 模式 + 个人信息会得到同一张卡片（方便分享）。';

  @override
  String get dailyContentUnavailableTitle => '每日花语不可用';

  @override
  String get dailyContentUnavailableBody => 'Botanica 暂时无法加载今日花语内容，请重试。';

  @override
  String get dailyProfileMissingTitle => '完善个人信息';

  @override
  String get dailyProfileMissingBody => '请先在「我的」中设置个人关键字（例如昵称）或生日，让每日花语更贴合你。';

  @override
  String get dailyProfileMissingBodyZodiac => '请先在「我的」中设置你的生日或星座，让每日花语更贴合你。';

  @override
  String get dailyProfileMissingCta => '去设置';

  @override
  String get careKeyLight => '光照';

  @override
  String get careKeyWater => '浇水';

  @override
  String get careKeyTemperature => '温度';

  @override
  String get careKeyPetSafety => '宠物安全';

  @override
  String get profileTitle => '我的';

  @override
  String get profileSectionPreferences => '偏好';

  @override
  String get profileSectionPermissions => '权限';

  @override
  String get profileSectionData => '数据';

  @override
  String get profileSectionAbout => '关于';

  @override
  String get storageHealthTitle => '存储健康';

  @override
  String get storageHealthSubtitle => '查看日记媒体并清理临时文件。';

  @override
  String get storageJournalPhotos => '日记照片';

  @override
  String get storageUsed => '已用存储';

  @override
  String get storagePhotoFiles => '照片文件';

  @override
  String get storageJournalEntries => '日记条目';

  @override
  String get storagePhotoEntries => '照片条目';

  @override
  String get storageMissingPhotos => '缺失照片';

  @override
  String get storageCacheTitle => '临时缓存';

  @override
  String get storageCacheBody => '清理生成的分享卡片和临时文件，不会删除你的日记照片。';

  @override
  String get storageClearCache => '清理缓存';

  @override
  String get storageCacheCleared => '临时缓存已清理。';

  @override
  String storageFileCount(int count) {
    return '$count 个文件';
  }

  @override
  String storageEntryCount(int count) {
    return '$count 条';
  }

  @override
  String get exportDataTitle => '导出养护数据';

  @override
  String get exportDataSubtitle => '将植物和养护记录保存为 JSON 文件。';

  @override
  String get exportDataSuccess => '养护数据导出成功。';

  @override
  String get exportDataEmpty => '暂无数据可导出——先添加一些植物吧。';

  @override
  String get profileLanguage => '语言';

  @override
  String get profileUnits => '单位';

  @override
  String get profileHemisphereTitle => '半球';

  @override
  String get profileHemisphereBody => '用于季节性养护调整（冬季/夏季）。';

  @override
  String get hemisphereNorthern => '北半球';

  @override
  String get hemisphereSouthern => '南半球';

  @override
  String get profileBeliefMode => '每日模式';

  @override
  String get profileDailyProfileTitle => '每日个性化';

  @override
  String profileDailyProfileBody(String mode) {
    return '为「$mode」选择你的个人信息。';
  }

  @override
  String get profileBirthdateTitle => '生日';

  @override
  String get profileBirthdateBody => '用于星座与黄历等模式的个性化。';

  @override
  String get profileDailySeedTitle => '个人关键字';

  @override
  String get profileDailySeedBody => '一段简短的关键字（比如昵称），用于个性化每日花语，但不会改变你的模式。';

  @override
  String get profileDailySeedHint => '例如：Aster';

  @override
  String get profileDailyProfileUseBirthdate => '使用生日';

  @override
  String get profileDailyProfileNotSet => '未设置';

  @override
  String get profileDailyProfileKeySet => '已设置';

  @override
  String get profileDailyProfileNotNeeded => '此模式无需个人信息。';

  @override
  String get profileDailyProfilePickModeFirst => '请先选择每日模式，再在这里进行设置。';

  @override
  String get profileDailyProfileTarotSubtitle => '在「每日」抽牌';

  @override
  String get profileDailyProfileAutoSubtitle => '自动（按日期）';

  @override
  String get profileDailyProfileTarotBody =>
      '塔罗模式是每日小仪式：在「每日」里发四张牌并选择一张，然后揭晓今日之花。';

  @override
  String get profileDailyProfileTarotCta => '打开「每日」';

  @override
  String profileDailyProfileAutoBody(String mode) {
    return '$mode 会基于当天日期进行每日抽取，并结合个人信息进行个性化。';
  }

  @override
  String get profileDailyProfileLocalDefault => '使用你的语言';

  @override
  String get profileLocalTraditionKeyTitle => '文化关键字';

  @override
  String get profileLocalTraditionKeyHint => '例如：global、china、japan…';

  @override
  String get profilePhotos => '照片';

  @override
  String get profileNotifications => '通知';

  @override
  String get profileLocation => '位置';

  @override
  String get profilePrivacy => '隐私';

  @override
  String get profileBackup => '备份';

  @override
  String get profileCredits => '致谢';

  @override
  String get profileDynamicColorTitle => '动态配色';

  @override
  String get profileDynamicColorBody => '在支持的设备上使用系统配色。';

  @override
  String get vacationModeTitle => '假期模式';

  @override
  String get vacationModeOff => '外出时暂停所有提醒。';

  @override
  String vacationModeActiveUntil(String date) {
    return '有效至 $date';
  }

  @override
  String get vacationModeEnd => '结束假期模式';

  @override
  String get vacationModePickDate => '返回日期';

  @override
  String get profileAiInsightsTitle => 'AI 灵感';

  @override
  String get profileAiInsightsBody => '以不打扰的方式，在页面里生成小提示，让每日花语更贴合你。';

  @override
  String get profileAiKeyTitle => 'AI API 密钥';

  @override
  String get profileAiKeyConfigured => '已设置';

  @override
  String get profileAiKeyNotSet => '未设置';

  @override
  String get profileAiKeyNotRequired => '不需要';

  @override
  String get profileAiKeySheetBody => '密钥将安全保存在本设备上，仅用于生成简短的页面内提示，并会按你的语言设置返回。';

  @override
  String get profileAiKeyNotRequiredBody => '此构建版本使用无需鉴权的代理服务，因此不需要 API 密钥。';

  @override
  String get profileAiKeySheetHint => '粘贴你的 API 密钥';

  @override
  String get profileAiKeySaved => 'AI 密钥已保存。';

  @override
  String get profileAiKeyCleared => 'AI 密钥已移除。';

  @override
  String get profileLanguageSystem => '跟随系统';

  @override
  String get creditsTitle => '致谢';

  @override
  String get creditsOpenSource => '开源';

  @override
  String get creditsFlutterCommunity => 'Flutter 社区参考';

  @override
  String get creditsUiInspiration => 'UI 灵感';

  @override
  String get creditsPlaceholderNote =>
      '说明：本项目暂时使用白色 PNG 占位图，你可以在完成后替换为真实照片/插画资源。';

  @override
  String get unitsCelsius => '摄氏 (°C)';

  @override
  String get unitsFahrenheit => '华氏 (°F)';

  @override
  String get beliefModeWesternZodiac => '星座';

  @override
  String get beliefModeChineseZodiac => '生肖';

  @override
  String get beliefModeTarot => '塔罗抽牌';

  @override
  String get beliefModeLocalTraditions => '本地传统';

  @override
  String get beliefModeJustFlower => '只给我一朵花';

  @override
  String get beliefModeNotSet => '未设置';

  @override
  String get beliefModeAlmanac => '黄历';

  @override
  String get beliefModeOmikuji => '御神签';

  @override
  String get beliefModeRunes => '北欧符文';

  @override
  String get beliefModeOgham => '凯尔特欧甘字母';

  @override
  String get zodiacAries => '白羊座';

  @override
  String get zodiacTaurus => '金牛座';

  @override
  String get zodiacGemini => '双子座';

  @override
  String get zodiacCancer => '巨蟹座';

  @override
  String get zodiacLeo => '狮子座';

  @override
  String get zodiacVirgo => '处女座';

  @override
  String get zodiacLibra => '天秤座';

  @override
  String get zodiacScorpio => '天蝎座';

  @override
  String get zodiacSagittarius => '射手座';

  @override
  String get zodiacCapricorn => '摩羯座';

  @override
  String get zodiacAquarius => '水瓶座';

  @override
  String get zodiacPisces => '双鱼座';

  @override
  String get chineseZodiacRat => '生肖鼠';

  @override
  String get chineseZodiacOx => '生肖牛';

  @override
  String get chineseZodiacTiger => '生肖虎';

  @override
  String get chineseZodiacRabbit => '生肖兔';

  @override
  String get chineseZodiacDragon => '生肖龙';

  @override
  String get chineseZodiacSnake => '生肖蛇';

  @override
  String get chineseZodiacHorse => '生肖马';

  @override
  String get chineseZodiacGoat => '生肖羊';

  @override
  String get chineseZodiacMonkey => '生肖猴';

  @override
  String get chineseZodiacRooster => '生肖鸡';

  @override
  String get chineseZodiacDog => '生肖狗';

  @override
  String get chineseZodiacPig => '生肖猪';

  @override
  String get tarotTheFool => '愚者';

  @override
  String get tarotTheMagician => '魔术师';

  @override
  String get tarotTheHighPriestess => '女祭司';

  @override
  String get tarotTheEmpress => '女皇';

  @override
  String get tarotTheEmperor => '皇帝';

  @override
  String get tarotTheHierophant => '教皇';

  @override
  String get tarotTheLovers => '恋人';

  @override
  String get tarotTheChariot => '战车';

  @override
  String get tarotStrength => '力量';

  @override
  String get tarotTheHermit => '隐者';

  @override
  String get tarotWheelOfFortune => '命运之轮';

  @override
  String get tarotJustice => '正义';

  @override
  String get tarotTheHangedMan => '倒吊人';

  @override
  String get tarotDeath => '死神';

  @override
  String get tarotTemperance => '节制';

  @override
  String get tarotTheDevil => '恶魔';

  @override
  String get tarotTheTower => '高塔';

  @override
  String get tarotTheStar => '星星';

  @override
  String get tarotTheMoon => '月亮';

  @override
  String get tarotTheSun => '太阳';

  @override
  String get tarotJudgement => '审判';

  @override
  String get tarotTheWorld => '世界';

  @override
  String get omikujiDaikichi => '大吉';

  @override
  String get omikujiChukichi => '中吉';

  @override
  String get omikujiShokichi => '小吉';

  @override
  String get omikujiKichi => '吉';

  @override
  String get omikujiHankichi => '半吉';

  @override
  String get omikujiSuekichi => '末吉';

  @override
  String get omikujiKyo => '凶';

  @override
  String get omikujiDaikyo => '大凶';

  @override
  String get taskTypeWater => '浇水';

  @override
  String get taskTypeFertilize => '施肥';

  @override
  String get taskTypeMist => '喷雾';

  @override
  String get taskTypeRotate => '转盆';

  @override
  String get taskTypePrune => '修剪';

  @override
  String get taskTypeRepot => '换盆';

  @override
  String get taskTypeCheckPests => '检查虫害';

  @override
  String get taskTypeWipeLeaves => '擦叶';

  @override
  String get taskTypeSunlightAdjustment => '调整光照';

  @override
  String notificationsTaskTitle(String plant, String task) {
    return '$plant · $task';
  }

  @override
  String notificationsTaskBodyRoom(String room) {
    return '位置：$room';
  }

  @override
  String get notificationsTaskBodyNoRoom => '打开 Botanica 标记完成。';

  @override
  String notificationWaterTitle(String plant) {
    return '该给 $plant 浇水了';
  }

  @override
  String notificationFertilizeTitle(String plant) {
    return '今天给 $plant 施肥';
  }

  @override
  String notificationMistTitle(String plant) {
    return '$plant 想要一点喷雾';
  }

  @override
  String notificationRotateTitle(String plant) {
    return '给 $plant 转四分之一圈';
  }

  @override
  String notificationPruneTitle(String plant) {
    return '$plant 可以修剪了';
  }

  @override
  String notificationWaterTitle2(String plant) {
    return '$plant 有点渴了！';
  }

  @override
  String notificationWaterTitle3(String plant) {
    return '该给 $plant 浇水啦';
  }

  @override
  String notificationFertilizeTitle2(String plant) {
    return '$plant 需要补充营养';
  }

  @override
  String notificationFertilizeTitle3(String plant) {
    return '给 $plant 施肥的时间到了';
  }

  @override
  String notificationMistTitle2(String plant) {
    return '给 $plant 加点湿度？';
  }

  @override
  String notificationMistTitle3(String plant) {
    return '该给 $plant 喷雾了';
  }

  @override
  String notificationRotateTitle2(String plant) {
    return '转一转 $plant，让它均匀生长';
  }

  @override
  String notificationRotateTitle3(String plant) {
    return '$plant 今天需要转个方向';
  }

  @override
  String notificationPruneTitle2(String plant) {
    return '该给 $plant 修剪一下了';
  }

  @override
  String notificationPruneTitle3(String plant) {
    return '$plant 需要修整';
  }

  @override
  String get notificationDailySummaryTitle => '早安，植物家长！';

  @override
  String notificationDailySummaryBody(int count) {
    return '今天有 $count 项养护任务等着你。';
  }

  @override
  String get reasonHumidityLow => '湿度低 → 土壤更快变干';

  @override
  String get reasonHumidityHigh => '湿度高 → 土壤保持湿润更久';

  @override
  String get reasonHot => '温度高 → 蒸发更快';

  @override
  String get reasonSpring => '春季 → 生长恢复';

  @override
  String get reasonSummer => '夏季 → 蒸腾更强';

  @override
  String get reasonAutumn => '秋季 → 生长放缓';

  @override
  String get reasonWinter => '冬季 → 生长更慢';

  @override
  String get reasonOutdoor => '户外模式 → 更依赖天气预报';

  @override
  String get reasonIndoor => '室内模式 → 默认环境更稳定';

  @override
  String get envLightLow => '低光';

  @override
  String get envLightMedium => '中等光照';

  @override
  String get envLightHigh => '高光';

  @override
  String get envLabelTemp => '温度';

  @override
  String get envLabelHumidity => '湿度';

  @override
  String get envLabelLight => '光照';

  @override
  String get gardenWellnessTitle => '花园健康';

  @override
  String get gardenWellnessSubtitle => '查看评分、重点植物与护理负荷';

  @override
  String get gardenWellnessEmptyTitle => '还没有植物';

  @override
  String get gardenFilterEmptyTitle => '没有符合该筛选条件的植物。';

  @override
  String get gardenWellnessEmptyBody => '添加第一株植物以开启花园健康。';

  @override
  String get gardenWellnessOverallScore => '综合评分';

  @override
  String gardenWellnessOverdueChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 项逾期',
      one: '1 项逾期',
    );
    return '$_temp0';
  }

  @override
  String get gardenWellnessStatPlants => '植物';

  @override
  String get gardenWellnessStatRecentCare => '最近护理';

  @override
  String get gardenWellnessStatAtRisk => '需关注';

  @override
  String get gardenWellnessStatPunctuality => '准时率';

  @override
  String get gardenWellnessStatWeeklyActive => '周活跃';

  @override
  String get gardenWellnessStatBestStreak => '最长连续';

  @override
  String get gardenWellnessMomentumIncreasing => '势头上升';

  @override
  String get gardenWellnessMomentumDecreasing => '势头下降';

  @override
  String get gardenWellnessRoomPulseTitle => '房间状态';

  @override
  String gardenWellnessRoomPulseSummary(int plantCount, int overdueCount) {
    return '$plantCount 株植物 · $overdueCount 项逾期';
  }

  @override
  String get gardenWellnessRoomPulseStable => '稳定';

  @override
  String gardenWellnessRoomPulseAtRisk(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 株需关注',
      one: '1 株需关注',
    );
    return '$_temp0';
  }

  @override
  String get gardenWellnessPrioritiesTitle => '今日优先事项';

  @override
  String get gardenWellnessFocusPlantsTitle => '重点植物';

  @override
  String get gardenWellnessScoreLabel => '评分';

  @override
  String get gardenWellnessScoreFlourishing => '生长良好';

  @override
  String get gardenWellnessScoreSteady => '状态稳定';

  @override
  String get gardenWellnessScoreNeedsLittleCare => '需要稍加照料';

  @override
  String get gardenWellnessScoreNeedsAttention => '需要关注';

  @override
  String gardenWellnessFocusReasonOverdueAndNoLog(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 项逾期 · 缺少最近记录',
      one: '1 项逾期 · 缺少最近记录',
    );
    return '$_temp0';
  }

  @override
  String gardenWellnessFocusReasonOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 项逾期',
      one: '1 项逾期',
    );
    return '$_temp0';
  }

  @override
  String get gardenWellnessFocusReasonNoLog => '14 天内没有最近记录';

  @override
  String get gardenWellnessFocusReasonSteady => '状态稳定';

  @override
  String gardenWellnessPriorityAttentionTitle(String plantName) {
    return '看看 $plantName';
  }

  @override
  String gardenWellnessPriorityAttentionBodyOverdueAndNoLog(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 项逾期且缺少最近记录。',
      one: '1 项逾期且缺少最近记录。',
    );
    return '$_temp0';
  }

  @override
  String gardenWellnessPriorityAttentionBodyOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 项逾期需要处理。',
      one: '1 项逾期需要处理。',
    );
    return '$_temp0';
  }

  @override
  String get gardenWellnessPriorityAttentionBodyNoLog => '最近 14 天没有新的记录。';

  @override
  String get gardenWellnessPriorityAttentionBodyCheckIn => '这株植物需要快速查看一下。';

  @override
  String get gardenWellnessPriorityDueTodayTitle => '把今天安排好';

  @override
  String gardenWellnessPriorityDueTodayBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '今天有 $count 项任务到期。',
      one: '今天有 1 项任务到期。',
    );
    return '$_temp0';
  }

  @override
  String get gardenWellnessPriorityRefreshHistoryTitle => '更新护理记录';

  @override
  String gardenWellnessPriorityRefreshHistoryBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 株植物缺少最近记录。',
      one: '1 株植物缺少最近记录。',
    );
    return '$_temp0';
  }

  @override
  String get gardenWellnessPriorityCalmTitle => '享受这份平静';

  @override
  String get gardenWellnessPriorityCalmBody => '今天没有紧急事项——你的花园状态稳定。';

  @override
  String get gardenWellnessRoomUnassigned => '未分配';

  @override
  String get editPlantTitle => '编辑植物';

  @override
  String get editPlantSaveButton => '保存更改';

  @override
  String get plantDetailMenuEdit => '编辑植物';

  @override
  String get plantDetailMenuArchive => '归档植物';

  @override
  String get plantDetailMenuDelete => '删除植物';

  @override
  String archivePlantTitle(String plantName) {
    return '归档 $plantName？';
  }

  @override
  String get archivePlantBody => '归档后的植物会从花园中隐藏，但会保留其历史记录。';

  @override
  String get archivePlantConfirm => '归档';

  @override
  String deletePlantTitle(String plantName) {
    return '删除 $plantName？';
  }

  @override
  String get deletePlantBody => '这会永久删除该植物及其全部历史记录，且无法撤销。';

  @override
  String get deletePlantConfirm => '删除';

  @override
  String restorePlantTitle(String plantName) {
    return '恢复 $plantName？';
  }

  @override
  String get restorePlantBody => '这会将该植物恢复到你的花园中，并继续其养护计划。';

  @override
  String get restorePlantConfirm => '恢复';

  @override
  String get gardenStatusArchived => '已归档';

  @override
  String get gardenSortTitle => '排序方式';

  @override
  String get gardenFilterArchived => '已归档';

  @override
  String get gardenSortCare => '护理需求';

  @override
  String get gardenSortName => '名称';

  @override
  String get gardenSortNewest => '最新添加';

  @override
  String get gardenSortHealth => '健康评分';

  @override
  String get gardenSortRoom => '房间';

  @override
  String get gardenSortSpecies => '物种';

  @override
  String get gardenSortNeedsCare => '需要护理';

  @override
  String get gardenFilterAll => '全部';

  @override
  String get gardenFilterHealthy => '健康';

  @override
  String get gardenFilterNeedsCare => '需要护理';

  @override
  String get gardenSearchHint => '搜索花园...';

  @override
  String archivePlantSuccess(String nickname) {
    return '$nickname 已归档。';
  }

  @override
  String restorePlantSuccess(String nickname) {
    return '$nickname 已恢复。';
  }

  @override
  String deletePlantSuccess(String nickname) {
    return '$nickname 已删除。';
  }

  @override
  String get commonConfirm => '确认';

  @override
  String streakMilestoneTitle(int days) {
    return '连续$days天里程碑！';
  }

  @override
  String get streakMilestoneBody7 => '整整一周的植物护理，你的花园感谢你。';

  @override
  String get streakMilestoneBody30 => '坚持30天，你正在养成好习惯。';

  @override
  String get streakMilestoneBody90 => '90天！你的植物从未如此快乐。';

  @override
  String get streakMilestoneBody365 => '整整一年的护理，你是植物传奇。';

  @override
  String get streakMilestoneDismiss => '继续加油！';

  @override
  String timeCapsuleTitle(int days) {
    return '$days天前的今天';
  }

  @override
  String timeCapsuleBody(String plant, int days) {
    return '你在$days天前为$plant拍下了这张照片。看看你们一起走了多远。';
  }

  @override
  String get rescueResetTitle => '欢迎回来';

  @override
  String rescueResetBody(int streak, int days) {
    return '你曾有$streak天的连续记录。已经过了$days天——不必内疚，随时可以重新开始。';
  }

  @override
  String get rescueResetWaterNow => '现在浇一棵植物';

  @override
  String get rescueResetFreshStart => '重新开始';

  @override
  String streakSavedSnackbar(String plant, int days) {
    return '连续记录保住了！已照顾$plant · $days天节奏不变';
  }

  @override
  String get plantPulseTitle => '该拍照记录了';

  @override
  String plantPulseBody(String plant, int days) {
    return '$plant已经$days天没拍照了，看看它长了多少。';
  }

  @override
  String get plantPulseCta => '拍一张';

  @override
  String get plantJourneyTitle => '你们的旅程';

  @override
  String plantJourneyNextMilestone(String milestone) {
    return '下一个：$milestone';
  }

  @override
  String get plantJourneyMilestoneFirstWater => '第一次浇水';

  @override
  String get plantJourneyMilestoneFirstPhoto => '第一张照片';

  @override
  String get plantJourneyMilestone7Days => '相伴7天';

  @override
  String get plantJourneyMilestoneFirstFertilize => '第一次施肥';

  @override
  String get plantJourneyMilestone10Waters => '浇水10次';

  @override
  String get plantJourneyMilestone30Days => '相伴30天';

  @override
  String get plantJourneyMilestone25Waters => '浇水25次';

  @override
  String get plantJourneyMilestone100Days => '相伴100天';

  @override
  String get plantJourneyMilestone365Days => '相伴一年';

  @override
  String get gardenerTypeTitle => '你的园丁类型';

  @override
  String get gardenerTypeDevoted => '专注型';

  @override
  String get gardenerTypeDevotedDesc => '连续30天以上不间断照顾，植物们都爱你。';

  @override
  String get gardenerTypeConsistent => '稳定型';

  @override
  String get gardenerTypeConsistentDesc => '超过80%的任务按时完成，像时钟一样可靠。';

  @override
  String get gardenerTypeExplorer => '探索型';

  @override
  String get gardenerTypeExplorerDesc => '收藏了5种以上植物，真正的植物探索家。';

  @override
  String get gardenerTypePhotographer => '记录型';

  @override
  String get gardenerTypePhotographerDesc => '10张以上成长照片，每片叶子都有故事。';

  @override
  String get gardenerTypeNurturer => '呵护型';

  @override
  String get gardenerTypeNurturerDesc => '50次以上养护操作，花园因你的关注而繁茂。';

  @override
  String get gardenerTypeBudding => '新手园丁';

  @override
  String get gardenerTypeBuddingDesc => '每个专家都曾是新手，继续成长吧！';

  @override
  String get whispererTierSeedling => '种子';

  @override
  String get whispererTierSprout => '嫩芽';

  @override
  String get whispererTierGardener => '园丁';

  @override
  String get whispererTierBotanist => '植物学家';

  @override
  String get whispererTierWhisperer => '植物低语者';

  @override
  String whispererNextLevel(int xp) {
    return '距下一级还需 $xp XP';
  }

  @override
  String careCombo(int count) {
    return '$count连击！';
  }

  @override
  String careComboStreak(int count) {
    return '$count连击！势不可挡！';
  }

  @override
  String get lastCareWater => '浇水';

  @override
  String get lastCareFertilize => '施肥';

  @override
  String get lastCarePhoto => '拍照';

  @override
  String lastCareDaysAgo(int days) {
    return '$days天前';
  }

  @override
  String get lastCareToday => '今天';

  @override
  String get lastCareNever => '—';

  @override
  String careConfidenceOnSchedule(int days) {
    return '正好按节奏来（平均$days天）';
  }

  @override
  String get careConfidenceEarly => '稍微早了点——土壤可能还湿着';

  @override
  String get careConfidenceLate => '稍微晚了，不过没关系';

  @override
  String get gardenMoodThriving => '生机勃勃';

  @override
  String get gardenMoodHappy => '状态不错';

  @override
  String get gardenMoodNeedsLove => '需要关爱';

  @override
  String get gardenMoodThirsty => '渴了';

  @override
  String get plantDetailLogsSparklineTitle => '14天活动';

  @override
  String plantDetailLogsSparklineCount(int count) {
    return '$count次操作';
  }

  @override
  String get commonToday => '今天';

  @override
  String get calendarHeatmapTitle => '12周活动';

  @override
  String get profileStatsTotalCare => '总护理';

  @override
  String get profileStatsWatered => '浇水';

  @override
  String get profileStatsFertilized => '施肥';

  @override
  String profileStatsActions(int count) {
    return '$count';
  }

  @override
  String get profileCareScore => '养护评分';

  @override
  String profileCareScoreLabel(int percent) {
    return '$percent%';
  }

  @override
  String get profileCareScoreSubtitle => '近30天按时完成率';

  @override
  String get weeklyRecapTitle => '本周回顾';

  @override
  String get weeklyRecapActiveDays => '活跃天数';

  @override
  String weeklyRecapSummary(int actions, int days) {
    return '本周 $days 天内完成了 $actions 次养护';
  }

  @override
  String get weeklyRecapDismiss => '干得漂亮！';

  @override
  String weeklyRecapBestDay(String day) {
    return '最佳日：$day';
  }

  @override
  String weeklyRecapStreak(int days) {
    return '连续：$days 天';
  }

  @override
  String get gardenAllTasksDoneTitle => '今天全部完成！';

  @override
  String get gardenAllTasksDoneBody => '每棵植物都很开心，享受你的一天吧。';

  @override
  String get gardenAllDoneBody2 => '你的绿色朋友们因你而茁壮成长。';

  @override
  String get gardenAllDoneBody3 => '坚持就是秘诀，你做到了。';

  @override
  String get gardenAllDoneBody4 => '又是出色的植物养护日。';

  @override
  String get gardenAllDoneBody5 => '你的植物每天都在变得更强壮。';

  @override
  String profileLongestStreak(int days) {
    return '最佳：$days 天';
  }

  @override
  String profileGardenAge(int days) {
    return '花园：$days 天';
  }

  @override
  String gardenNewPersonalBest(int days) {
    return '新纪录！连续 $days 天';
  }

  @override
  String gardenTomorrowPreview(int count) {
    return '明天：$count 棵植物需要照料';
  }

  @override
  String get gardenMotivation7DayStreak => '势头正好，继续保持。';

  @override
  String get gardenMotivation30DayStreak => '坚持一个月了，植物们正在茁壮成长。';

  @override
  String get gardenMotivationWelcomeBack => '欢迎回来，植物们想你了。';

  @override
  String get gardenMotivationBigGarden => '花园繁茂，你做得很好。';

  @override
  String get gardenMotivationMorning => '美好的一天，去看看你的绿色朋友吧。';

  @override
  String get gardenMotivationEvening => '放松一下，快速检查花园。';

  @override
  String get gardenMotivationAllDoneToday => '今天全部完成，植物们很开心。';

  @override
  String get gardenMotivationNewPlant => '你的新植物正在适应新环境。';

  @override
  String gardenStreakFreezeUsed(int days) {
    return '使用了连续冻结！你的 $days 天连续记录安全了。';
  }

  @override
  String gardenStreakFreezeEarned(int count) {
    return '获得连续冻结！（可用 $count 次）';
  }

  @override
  String profileStreakFreezes(int count) {
    return '可用 $count 次冻结';
  }

  @override
  String gardenPlantMilestone(int count) {
    return '花园里有 $count 棵植物了！你的收藏越来越美。';
  }

  @override
  String get streakShareTitle => '分享你的连续记录';

  @override
  String streakShareCardDays(int days) {
    return '连续 $days 天';
  }

  @override
  String get streakShareCardSubtitle => '每天用心照顾我的植物';

  @override
  String get streakShareButton => '分享';

  @override
  String get plantLastWateredToday => '今天已浇水';

  @override
  String get plantLastWateredYesterday => '昨天浇过水';

  @override
  String plantLastWateredDaysAgo(int days) {
    return '$days 天前浇过水';
  }

  @override
  String get plantNeverWatered => '尚未浇水';

  @override
  String plantAgeLabel(int days) {
    return '入住花园 $days 天';
  }

  @override
  String plantAnniversaryLabel(int years) {
    return '$years 周年纪念！';
  }

  @override
  String get careLogAddNote => '添加备注';

  @override
  String get careLogEditNote => '编辑备注';

  @override
  String get careLogNoteHint => '它看起来怎么样？有什么需要记住的吗？';

  @override
  String get careLogNoteSaved => '备注已保存';

  @override
  String get careStatsTitle => '养护规律';

  @override
  String get careStatsTotalWaterings => '浇水次数';

  @override
  String get careStatsAvgInterval => '平均间隔';

  @override
  String careStatsAvgDays(int days) {
    return '$days天';
  }

  @override
  String get careStatsTotalActions => '总操作';

  @override
  String get careStatsConsistency => '规律性';

  @override
  String get careStatsTip => '试试设置定期提醒，养成稳定的浇水习惯。';

  @override
  String get gardenForecastTitle => '未来 7 天';

  @override
  String gardenForecastTaskCount(int count) {
    return '$count 项任务';
  }

  @override
  String gardenForecastBusyDay(String day) {
    return '最忙：$day';
  }

  @override
  String get gardenForecastEmpty => '本周暂无计划任务';

  @override
  String get gardenForecastToday => '今天';

  @override
  String get gardenForecastTomorrow => '明天';

  @override
  String get wellnessHeatmapTitle => '养护活动';

  @override
  String get wellnessHeatmapSubtitle => '最近 12 周';

  @override
  String wellnessHeatmapActions(int count) {
    return '$count 次操作';
  }

  @override
  String gardenWeeklyTrendUp(int diff) {
    return '比上周 +$diff';
  }

  @override
  String gardenWeeklyTrendDown(int diff) {
    return '比上周 $diff';
  }

  @override
  String get gardenWeeklyTrendSame => '与上周持平';

  @override
  String gardenWeeklyMostActiveDay(String day) {
    return '最活跃：$day';
  }

  @override
  String get achievementsTitle => '成就';

  @override
  String achievementsUnlocked(int count, int total) {
    return '$count/$total 已解锁';
  }

  @override
  String get achievementFirstPlant => '第一棵芽';

  @override
  String get achievementFirstPlantDesc => '添加你的第一棵植物';

  @override
  String get achievementFivePlants => '成长中的花园';

  @override
  String get achievementFivePlantsDesc => '花园达到 5 棵植物';

  @override
  String get achievementTenPlants => '植物爱好者';

  @override
  String get achievementTenPlantsDesc => '花园达到 10 棵植物';

  @override
  String get achievementTwentyPlants => '丛林大师';

  @override
  String get achievementTwentyPlantsDesc => '培育 20 棵植物';

  @override
  String get achievementFirstCare => '第一滴水';

  @override
  String get achievementFirstCareDesc => '完成第一个养护任务';

  @override
  String get achievementFiftyCares => '尽心照料';

  @override
  String get achievementFiftyCaresDesc => '完成 50 个养护任务';

  @override
  String get achievementHundredCares => '绿手指';

  @override
  String get achievementHundredCaresDesc => '完成 100 个养护任务';

  @override
  String get achievementFiveHundredCares => '植物低语者';

  @override
  String get achievementFiveHundredCaresDesc => '完成 500 个养护任务';

  @override
  String get achievementWeekStreak => '一周勇士';

  @override
  String get achievementWeekStreakDesc => '保持 7 天连续养护';

  @override
  String get achievementMonthStreak => '月度坚持';

  @override
  String get achievementMonthStreakDesc => '保持 30 天连续养护';

  @override
  String get achievementYearStreak => '传奇园丁';

  @override
  String get achievementYearStreakDesc => '保持 365 天连续养护';

  @override
  String get achievementFirstPhoto => '快照';

  @override
  String get achievementFirstPhotoDesc => '拍摄第一张植物照片';

  @override
  String get achievementTenPhotos => '照片日记';

  @override
  String get achievementTenPhotosDesc => '拍摄 10 张植物照片';

  @override
  String get achievementFiftyPhotos => '视觉叙事者';

  @override
  String get achievementFiftyPhotosDesc => '拍摄 50 张植物照片';

  @override
  String get achievementThreeRooms => '房间探索者';

  @override
  String get achievementThreeRoomsDesc => '在 3 个不同房间放置植物';

  @override
  String get achievementFiveRooms => '全屋花园';

  @override
  String get achievementFiveRoomsDesc => '在 5 个不同房间放置植物';

  @override
  String get achievementDiverseCarer => '全能园丁';

  @override
  String get achievementDiverseCarerDesc => '执行 5 种不同的养护类型';

  @override
  String get tasksCompleteAll => '全部完成';

  @override
  String tasksCompleteAllDone(int count) {
    return '已完成 $count 个任务';
  }

  @override
  String get tasksStreakAtRiskTitle => '连续记录即将中断！';

  @override
  String tasksStreakAtRiskBody(int days) {
    return '你的 $days 天连续记录今晚就要结束了。完成一个任务来保持它。';
  }

  @override
  String get plantMilestoneOneMonth => '相伴 1 个月！';

  @override
  String get plantMilestoneThreeMonths => '相伴 3 个月！';

  @override
  String get plantMilestoneSixMonths => '半年的呵护！';

  @override
  String get plantMilestoneOneYear => '一周年纪念！';

  @override
  String get plantMilestoneTwoYears => '两年的成长！';

  @override
  String plantMilestoneSubtitle(String name, int days) {
    return '你已经照顾 $name $days 天了';
  }

  @override
  String get seasonalTipTitle => '季节小贴士';

  @override
  String get seasonalTipSpringRepotTitle => '换盆好时机';

  @override
  String get seasonalTipSpringRepotBody => '春天是换盆的最佳时机。植物正进入生长期，能快速从换盆压力中恢复。';

  @override
  String get seasonalTipSpringFertilizeTitle => '恢复施肥';

  @override
  String get seasonalTipSpringFertilizeBody => '随着日照变长，重新开始施肥。先用半浓度，几周内逐渐增加。';

  @override
  String get seasonalTipSpringGrowthTitle => '关注新芽';

  @override
  String get seasonalTipSpringGrowthBody =>
      '你的植物正在苏醒。留意新叶、新芽和新根——这是拍摄成长照片的好时机。';

  @override
  String get seasonalTipSpringWaterTitle => '增加浇水';

  @override
  String get seasonalTipSpringWaterBody => '随着生长加速，植物需要更多水分。比冬天更频繁地检查土壤湿度。';

  @override
  String get seasonalTipSpringPestsTitle => '虫害巡查';

  @override
  String get seasonalTipSpringPestsBody => '温暖天气带来害虫。定期检查新芽和叶片背面，及早发现虫害迹象。';

  @override
  String get seasonalTipSummerWaterTitle => '保持水分';

  @override
  String get seasonalTipSummerWaterBody => '高温和长日照意味着蒸发加快。深浇水并更频繁检查土壤，尤其是小盆植物。';

  @override
  String get seasonalTipSummerMistTitle => '增加湿度';

  @override
  String get seasonalTipSummerMistBody => '空调会使空气干燥。给热带植物喷雾或将它们聚在一起，营造湿润的小环境。';

  @override
  String get seasonalTipSummerSunburnTitle => '注意晒伤';

  @override
  String get seasonalTipSummerSunburnBody =>
      '正午强烈的阳光会灼伤叶片。将敏感植物从朝南窗户移开或加装薄纱窗帘。';

  @override
  String get seasonalTipSummerOutdoorTitle => '户外时光';

  @override
  String get seasonalTipSummerOutdoorBody => '许多室内植物喜欢夏天的户外假期。逐渐适应，在夜间变冷前搬回室内。';

  @override
  String get seasonalTipSummerPropagateTitle => '扦插繁殖季';

  @override
  String get seasonalTipSummerPropagateBody =>
      '夏天的温暖和长日照使这成为扦插的理想时机。大多数插条在明亮散射光下能快速生根。';

  @override
  String get seasonalTipAutumnWaterTitle => '减少浇水';

  @override
  String get seasonalTipAutumnWaterBody =>
      '随着日照缩短，生长放缓。让土壤在两次浇水之间更加干燥，防止过渡期根腐。';

  @override
  String get seasonalTipAutumnFertilizeTitle => '停止施肥';

  @override
  String get seasonalTipAutumnFertilizeBody =>
      '大多数植物即将进入休眠期。停止施肥以避免盐分积累，让它们自然休息。';

  @override
  String get seasonalTipAutumnLightTitle => '追逐光线';

  @override
  String get seasonalTipAutumnLightBody => '随着太阳角度降低，将植物移近窗户。定期转动花盆，让各面均匀受光。';

  @override
  String get seasonalTipAutumnInsideTitle => '搬回室内';

  @override
  String get seasonalTipAutumnInsideBody => '如果夏天把植物搬到了户外，在夜间温度降到10°C以下之前搬回室内。';

  @override
  String get seasonalTipAutumnCleanTitle => '清洁叶片日';

  @override
  String get seasonalTipAutumnCleanBody => '灰尘会阻碍光合作用。用湿布擦拭叶片，帮助植物在冬天高效进行光合作用。';

  @override
  String get seasonalTipWinterWaterTitle => '少量浇水';

  @override
  String get seasonalTipWinterWaterBody => '大多数植物冬天需水量大减。休眠期过度浇水是头号杀手——拿不准就等等。';

  @override
  String get seasonalTipWinterHumidityTitle => '对抗干燥空气';

  @override
  String get seasonalTipWinterHumidityBody =>
      '暖气系统会大幅降低室内湿度。使用加湿器或鹅卵石托盘让热带植物保持舒适。';

  @override
  String get seasonalTipWinterDraftsTitle => '避免冷风';

  @override
  String get seasonalTipWinterDraftsBody => '让植物远离通风的窗户和外门。即使耐寒植物也不喜欢突然的温度变化。';

  @override
  String get seasonalTipWinterLightTitle => '最大化光照';

  @override
  String get seasonalTipWinterLightBody =>
      '短日照意味着光合作用减少。将植物移到最亮的位置，考虑为喜光植物添加补光灯。';

  @override
  String get seasonalTipWinterRestTitle => '让它们休息';

  @override
  String get seasonalTipWinterRestBody => '休眠是自然且健康的。不要担心生长缓慢——你的植物正在为春天储存能量。';

  @override
  String get healthBreakdownTitle => '健康评分';

  @override
  String get healthBreakdownSubtitle => '以下因素影响这株植物的健康评分';

  @override
  String healthBreakdownOverall(int score) {
    return '综合评分：$score/100';
  }

  @override
  String get healthFactorOverdue => '任务及时性';

  @override
  String get healthFactorActivity => '近期养护活动';

  @override
  String get healthFactorVariety => '养护多样性';

  @override
  String get healthFactorConsistency => '计划一致性';

  @override
  String get coachingTitle => '养护指导';

  @override
  String get coachingLateWatererTitle => '调整提醒时间';

  @override
  String get coachingLateWatererBody => '你经常晚一两天浇水。试着把提醒时间调到你通常有空的时候。';

  @override
  String get coachingStreakAtRiskTitle => '连续记录有风险！';

  @override
  String get coachingStreakAtRiskBody => '你今天还没有照顾任何植物。快速浇一次水就能保持连续记录。';

  @override
  String get coachingNeglectedPlantTitle => '有植物需要你';

  @override
  String get coachingNeglectedPlantBody => '你有一株植物超过3周没有得到照顾了。去看看它吧。';

  @override
  String get coachingImprovingTitle => '你在进步！';

  @override
  String get coachingImprovingBody => '这周你比上周更活跃了。继续保持这个势头。';

  @override
  String get coachingConsistentTitle => '一致性冠军';

  @override
  String get coachingConsistentBody => '你最近10个任务中有9个按时完成。你的植物正在茁壮成长。';

  @override
  String get coachingDiversifyTitle => '尝试新事物';

  @override
  String get coachingDiversifyBody => '你最近只在浇水。考虑喷雾、转盆或施肥，让植物更健康。';

  @override
  String get plantDetailNextWateringTomorrow => '明天';

  @override
  String get plantDetailNextWateringToday => '今天到期';

  @override
  String gardenStreakFreezeAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个连续冻结可用',
      one: '1个连续冻结可用',
    );
    return '$_temp0';
  }

  @override
  String get commonDismiss => '关闭';

  @override
  String get plantDetailHealthScore => '健康评分';

  @override
  String get plantDetailExpandText => '展开文本';

  @override
  String get plantDetailCollapseText => '收起文本';

  @override
  String get gardenWateredToday => '今天已浇水';

  @override
  String get gardenWateredYesterday => '昨天已浇水';

  @override
  String gardenWateredDaysAgo(int days) {
    return '$days天前浇水';
  }

  @override
  String get gardenNeverWatered => '尚未浇水';

  @override
  String calendarHeatmapTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次养护',
    );
    return '$_temp0';
  }

  @override
  String calendarHeatmapTooltipDetail(
      int waters, String fertSep, int fertilizes, String otherSep, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      waters,
      locale: localeName,
      other: '$waters 次浇水',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      fertilizes,
      locale: localeName,
      other: '$fertilizes 次施肥',
      zero: '',
    );
    String _temp2 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others 次其他',
      zero: '',
    );
    return '$_temp0$fertSep$_temp1$otherSep$_temp2';
  }

  @override
  String calendarDayCareCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条养护记录',
    );
    return '$_temp0';
  }

  @override
  String get exportDataConfirmTitle => '导出养护数据？';

  @override
  String get exportDataConfirmBody => '将创建包含所有植物、养护记录和任务的 JSON 文件。';

  @override
  String get exportDataConfirmAction => '导出';

  @override
  String get gardenWaterAllOverdue => '浇灌所有逾期植物';

  @override
  String gardenWaterAllOverdueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '浇灌 $count 棵逾期植物',
    );
    return '$_temp0';
  }

  @override
  String gardenWateredAllOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已浇灌 $count 棵逾期植物',
    );
    return '$_temp0';
  }

  @override
  String get plantOverviewNoCareStats => '多浇几次水后，养护规律将在此显示。';

  @override
  String get plantOverviewNoAiInsights => '在设置中启用 AI 洞察，获取个性化养护建议。';

  @override
  String get plantOverviewNoTasksYet => '暂无待办任务。养护计划创建后将在此显示。';

  @override
  String get gardenHealthTrendUp => '改善中';

  @override
  String get gardenHealthTrendDown => '下降中';

  @override
  String get gardenHealthTrendStable => '稳定';

  @override
  String plantCareStreakLabel(int days) {
    return '连续照顾 $days 天';
  }

  @override
  String get tasksEmptySoonMotivation => '享受这份宁静，你的植物正在茁壮成长。';

  @override
  String get manageCareTitle => '管理养护提醒';

  @override
  String manageCareSubtitle(int active, int disabled) {
    return '$active 项启用 · $disabled 项停用';
  }

  @override
  String get manageCareSpeciesDefault => '物种默认';

  @override
  String get manageCareEnabledByYou => '已手动启用';

  @override
  String get manageCareDisabledByYou => '已手动停用';

  @override
  String get manageCareButton => '管理';

  @override
  String manageCareDisableConfirm(String type) {
    return '关闭$type提醒？';
  }

  @override
  String get manageCareEnabled => '已启用';

  @override
  String get manageCareDisabled => '已停用';

  @override
  String get growthEchoCompareTitle => '今昔对比';

  @override
  String growthEchoCompareBody(String plant, int days) {
    return '$plant有$days天的生长变化可以对比。';
  }

  @override
  String get growthEchoCaptureTitle => '生长记录';

  @override
  String growthEchoCaptureBody(int days, String plant) {
    return '距离$plant上次拍照已经$days天了。';
  }

  @override
  String get commonProblemsTitle => '常见问题';

  @override
  String commonProblemsSubtitle(String plant) {
    return '注意$plant可能出现的这些情况';
  }

  @override
  String perfectWeekTitle(int count) {
    return '完美一周 $count!';
  }

  @override
  String get perfectWeekBody => '连续7天按时完成所有任务。你的植物因你而茁壮成长。';

  @override
  String perfectWeekBodyRepeat(int count) {
    return '连续$count个完美周。你已经是植物护理大师了。';
  }

  @override
  String get perfectWeekDismiss => '继续加油!';

  @override
  String get growthTimelineTitle => '成长时间线';

  @override
  String get growthTimelineEmpty => '拍照记录植物的成长变化';

  @override
  String notificationStreakProtectionTitle(int days) {
    return '你的$days天连续记录即将中断!';
  }

  @override
  String get notificationStreakProtectionBody => '在午夜前完成一项护理任务来保持连续记录。';

  @override
  String get careRhythmTitle => '你的养护节奏';

  @override
  String careRhythmAvgInterval(int days) {
    return '平均每 $days 天浇水一次';
  }

  @override
  String get careRhythmConsistent => '非常规律';

  @override
  String get careRhythmImproving => '越来越规律';

  @override
  String get careRhythmNoData => '再浇几次水就能看到你的节奏了';

  @override
  String get plantMoodThriving => '茁壮成长！🌱';

  @override
  String get plantMoodHappy => '状态很好';

  @override
  String get plantMoodOkay => '还不错';

  @override
  String get plantMoodThirsty => '有点渴了…';

  @override
  String get plantMoodNeglected => '想你了…';

  @override
  String get plantMoodNewHere => '刚入住！';

  @override
  String plantAnniversaryTitle(String plant) {
    return '$plant 的纪念日快乐！';
  }

  @override
  String get plantAnniversaryBody30 => '一个月了，你正在创造美好的事物。';

  @override
  String get plantAnniversaryBody90 => '三个月的悉心照料，你的用心看得见。';

  @override
  String get plantAnniversaryBody180 => '半年了！这棵植物因你而茁壮。';

  @override
  String get plantAnniversaryBody365 => '整整一年，多么美妙的旅程。';

  @override
  String get plantAnniversaryDismiss => '继续加油！';

  @override
  String insightRhythmShift(String plant, String oldDays, String newDays) {
    return '$plant 的浇水节奏从每 $oldDays 天变为 $newDays 天';
  }

  @override
  String insightFavoriteCareDay(String percent, String day) {
    return '你 $percent% 的养护发生在周$day — 你的花园日';
  }

  @override
  String insightActiveTime(String period, String percent) {
    return '你是$period型植物家长 — $percent% 的养护在此时段';
  }

  @override
  String insightMostLovedPlant(String plant, String actions) {
    return '$plant 本月最受关注 — $actions 次养护';
  }

  @override
  String insightQuietThenBusy(String quietDays, String taskCount) {
    return '接下来 $quietDays 天清闲，之后有 $taskCount 个任务';
  }

  @override
  String insightCareAcceleration(String thisWeek, String lastWeek) {
    return '状态火热 — 本周 $thisWeek 次 vs 上周 $lastWeek 次';
  }

  @override
  String insightGardenGrowing(String total, String recent) {
    return '花园在壮大 — 现有 $total 株，最近新增 $recent 株';
  }

  @override
  String insightSeasonalActivity(
      String direction, String thisMonth, String lastMonth) {
    return '季节变化：本月$direction活跃（$thisMonth vs $lastMonth）';
  }

  @override
  String get insightSectionTitle => '花园洞察';

  @override
  String quickCheckInTitle(String plant) {
    return '$plant 看起来怎么样？';
  }

  @override
  String get quickCheckInSubtitle => '快速记录帮助追踪植物健康状况';

  @override
  String get quickCheckInThriving => '茁壮';

  @override
  String get quickCheckInOkay => '还行';

  @override
  String get quickCheckInWorried => '担心';

  @override
  String get diversityTitle => '生物多样性指数';

  @override
  String get diversitySpecies => '物种';

  @override
  String get diversityLightNeeds => '光照需求';

  @override
  String get diversityDifficulty => '难度';

  @override
  String get diversityEnvironment => '环境';

  @override
  String get diversitySuggestNewSpecies => '尝试添加不同的物种来增加多样性';

  @override
  String get diversitySuggestDifferentLight => '考虑添加不同光照需求的植物';

  @override
  String get diversitySuggestVaryDifficulty => '混合简单和有挑战性的植物';

  @override
  String get diversitySuggestOutdoor => '尝试户外植物来增加环境多样性';

  @override
  String get diversitySuggestAddPlants => '添加更多植物来提高多样性';

  @override
  String get momentumTitle => '花园动力';

  @override
  String momentumTrending(String direction) {
    return '趋势$direction';
  }

  @override
  String get momentumUp => '上升';

  @override
  String get momentumDown => '下降';

  @override
  String get momentumSteady => '平稳';

  @override
  String get momentumStreak => '连续';

  @override
  String get momentumActivity => '活跃度';

  @override
  String get momentumGrowth => '成长';

  @override
  String get batchPlannerTitle => '浇水计划';

  @override
  String batchPlannerEfficiency(int percent) {
    return '$percent%效率';
  }

  @override
  String batchPlannerDays(int count) {
    return '每周$count天浇水';
  }

  @override
  String batchPlannerPlants(int count) {
    return '$count株植物';
  }

  @override
  String get careImpactTitle => '你的养护影响';

  @override
  String get careImpactWaterings => '浇水';

  @override
  String get careImpactSaved => '挽救';

  @override
  String get careImpactTypes => '类型';

  @override
  String careImpactLongestCompanion(String name, int days) {
    return '最长陪伴：$name（$days天）';
  }

  @override
  String careImpactAvgResponse(String hours) {
    return '平均响应：$hours小时';
  }

  @override
  String get gardenLegacyTitle => '花园传承';

  @override
  String get gardenLegacyTotalCare => '总养护次数';

  @override
  String get gardenLegacyLongestSurvivor => '最长存活';

  @override
  String get gardenLegacyScore => '传承分数';

  @override
  String roomCompatibilityTitle(String room) {
    return '$room兼容性';
  }

  @override
  String roomCompatibilityPairings(int plants, int pairings) {
    return '$plants株植物，$pairings组搭配';
  }

  @override
  String get wateringEfficiencyTitle => '浇水效率';

  @override
  String wateringEfficiencyOptimal(int count, int total) {
    return '$count/$total最佳';
  }

  @override
  String get careAutopilotTitle => '养护自动建议';

  @override
  String careAutopilotUrgent(int count) {
    return '$count项紧急';
  }

  @override
  String get roomSuggestionsTitle => '房间建议';

  @override
  String roomSuggestionsMoves(int count) {
    return '$count项调整';
  }

  @override
  String get dailyFactTitle => '你知道吗？';

  @override
  String get seasonalTransitionTitle => '季节过渡';

  @override
  String seasonalTransitionWeeks(int weeks) {
    return '$weeks周后';
  }

  @override
  String get gardenInsightsTitle => '花园洞察';

  @override
  String get recommendedForYouTitle => '为你推荐';

  @override
  String recommendedGaps(String gaps) {
    return '缺口：$gaps';
  }

  @override
  String get plantMemoryFirstPhoto => '第一张照片';

  @override
  String get plantMemoryFirstCare => '第一次养护';

  @override
  String get plantMemoryAnniversary => '纪念日';

  @override
  String get plantMemoryBusiestDay => '最忙碌的一天';

  @override
  String get plantMemoryLongestGap => '最长间隔';

  @override
  String get plantMemoryComeback => '回归';

  @override
  String careAutopilotMore(int count) {
    return '+$count 条更多建议';
  }

  @override
  String wateringEfficiencyMore(int count) {
    return '+$count 更多';
  }

  @override
  String seasonalTransitionMore(int count) {
    return '+$count 项更多任务';
  }

  @override
  String get gardenProgressTitle => '花园智能';

  @override
  String gardenProgressUnlocked(int unlocked, int total) {
    return '$unlocked/$total';
  }

  @override
  String gardenProgressMilestonePlant(String feature) {
    return '再添加 1 株植物以解锁$feature';
  }

  @override
  String gardenProgressMilestoneLogs(int count, String feature) {
    return '再记录 $count 次养护以解锁$feature';
  }

  @override
  String get transitionMoveIndoors => '移入室内';

  @override
  String get transitionMoveOutdoors => '移至室外';

  @override
  String get transitionReduceWatering => '减少浇水';

  @override
  String get transitionIncreaseWatering => '增加浇水';

  @override
  String get transitionStartFertilizing => '开始施肥';

  @override
  String get transitionStopFertilizing => '停止施肥';

  @override
  String get transitionIncreaseHumidity => '增加湿度';

  @override
  String get transitionProtectFromFrost => '防冻保护';

  @override
  String get transitionProvideShadeCover => '提供遮阳';

  @override
  String get transitionResumeNormalCare => '恢复正常养护';

  @override
  String get dailyBriefingTitle => '每日简报';

  @override
  String get dailyBriefingAllCaughtUp => '一切就绪 — 你的花园正在茁壮成长！';

  @override
  String get weeklyInsightTitle => '每周洞察';

  @override
  String get dailyChallengeTitle => '每日挑战';

  @override
  String get dailyChallengeAccept => '接受';

  @override
  String get communityChallengesTitle => '社区挑战';

  @override
  String get dailyRitualTitle => '每日仪式';

  @override
  String get achievementsRecent => '最近';

  @override
  String get careEffectivenessTitle => '养护效果';

  @override
  String get scheduleTuningTitle => '日程调整';

  @override
  String get careBurnoutOverload => '检测到养护过载';

  @override
  String get careBurnoutStretched => '感到疲惫？';

  @override
  String get careLoadTitle => '养护负荷';

  @override
  String get careLoadThisWeek => '本周';

  @override
  String get careCoachTitle => '养护教练';

  @override
  String get careConfidenceTitle => '养护信心';

  @override
  String get careConsistencyTitle => '养护一致性';

  @override
  String get careCostsTitle => '养护成本';

  @override
  String get delegationPlanTitle => '委托计划';

  @override
  String get carePatternsTitle => '养护模式';

  @override
  String get carePersonaTitle => '你的养护人格';

  @override
  String get carePersonaStrengths => '优势';

  @override
  String get carePersonaGrowthAreas => '成长领域';

  @override
  String get nextWateringTitle => '下次浇水';

  @override
  String get careRoutinesTitle => '你的养护习惯';
}
