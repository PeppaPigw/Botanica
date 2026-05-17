// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Botanica';

  @override
  String get appTagline =>
      'Tu compañero personal de cuidado de plantas — sereno, hermoso y atento.';

  @override
  String get gardenNoScheduleYet => 'Sin calendario aún';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get commonSkip => 'Saltar';

  @override
  String get commonStart => 'Empezar';

  @override
  String get commonDone => 'Hecho';

  @override
  String get commonOverdue => 'Atrasada';

  @override
  String get commonUndo => 'Deshacer';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClear => 'Borrar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonShow => 'Mostrar';

  @override
  String get commonHide => 'Ocultar';

  @override
  String get commonLater => 'Más tarde';

  @override
  String get commonSearch => 'Buscar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonAdd => 'Añadir';

  @override
  String get commonSettings => 'Ajustes';

  @override
  String get commonUnits => 'Unidades';

  @override
  String get commonLanguage => 'Idioma';

  @override
  String get commonAbout => 'Acerca de';

  @override
  String get commonTryAgain => 'Reintentar';

  @override
  String get commonErrorTryAgain => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get commonComingSoon => 'Próximamente';

  @override
  String get commonLoading => 'Cargando…';

  @override
  String get commonViewAll => 'Ver todo';

  @override
  String get commonWhy => '¿Por qué?';

  @override
  String get commonIdeal => 'Ideal';

  @override
  String get commonTolerates => 'Tolera';

  @override
  String get commonSoil => 'Suelo';

  @override
  String get commonSoilPh => 'pH del suelo';

  @override
  String get commonWhen => 'Cuándo';

  @override
  String get commonHow => 'Cómo';

  @override
  String get commonPestsAndDiseases => 'Plagas y enfermedades';

  @override
  String get commonPrevention => 'Prevención';

  @override
  String get commonHeatwave => 'Ola de calor';

  @override
  String get commonFrost => 'Heladas';

  @override
  String get commonStorm => 'Tormenta';

  @override
  String get commonHeavyRain => 'Lluvia intensa';

  @override
  String get commonClimateHotDry => 'Caluroso / seco';

  @override
  String get commonClimateCoolWet => 'Fresco / húmedo';

  @override
  String get commonClimateStrategies => 'Estrategias climáticas';

  @override
  String get resourcesTitle => 'Recursos';

  @override
  String get resourceWikipedia => 'Wikipedia';

  @override
  String get resourceYouTube => 'YouTube';

  @override
  String get resourceBaiduBaike => 'Baidu Baike';

  @override
  String get resourceBilibili => 'Bilibili';

  @override
  String get resourceGbif => 'GBIF';

  @override
  String get resourceCareGuide => 'Guía de cuidado';

  @override
  String get resourceCopyLink => 'Copiar enlace';

  @override
  String get resourceLinkCopied => 'Enlace copiado';

  @override
  String get aiNoteCopied => 'Nota copiada';

  @override
  String get aiNoteCopyAction => 'Copiar nota';

  @override
  String get stateLoadFailedTitle => 'No se pudo cargar';

  @override
  String get stateLoadFailedBody =>
      'Comprueba tu conexión y vuelve a intentarlo.';

  @override
  String get stateNotAvailableTitle => 'No disponible';

  @override
  String get stateNotAvailableBody =>
      'Este contenido no está disponible en este momento.';

  @override
  String get navGarden => 'Jardín';

  @override
  String get navCalendar => 'Calendario';

  @override
  String get navDiscover => 'Descubrir';

  @override
  String get navDaily => 'Diario';

  @override
  String get navProfile => 'Perfil';

  @override
  String get calendarTitle => 'Calendario';

  @override
  String get calendarFilterAll => 'Todas';

  @override
  String get calendarFilterOther => 'Otras';

  @override
  String get calendarSectionConsistency => 'Consistencia';

  @override
  String get calendarPrevMonth => 'Mes anterior';

  @override
  String get calendarNextMonth => 'Mes siguiente';

  @override
  String get calendarSectionHistory => 'Historial de cuidados';

  @override
  String get calendarWeekAheadTitle => 'Próxima semana';

  @override
  String calendarWeekAheadCount(int count) {
    return '$count tareas';
  }

  @override
  String get calendarNoEvents => 'No hay registros para este día.';

  @override
  String get splashTagline => 'Cuidado sereno, bellamente organizado.';

  @override
  String get onboardingTitle1 => 'Dale vida a tu espacio';

  @override
  String get onboardingBody1 =>
      'Sigue el rastro de tus plantas, crea una hermosa línea de tiempo y cultiva la calma.';

  @override
  String get onboardingTitle2 => 'Botanica aprende tu luz';

  @override
  String get onboardingBody2 =>
      'Un cuidado que se adapta a tu entorno: estación, humedad y temperatura.';

  @override
  String get onboardingTitle3 => 'Un ritual diario de crecimiento';

  @override
  String get onboardingBody3 =>
      'Descubre plantas con delicadeza y centra tu mente con inspiración botánica diaria.';

  @override
  String get onboardingCta => 'Entrar a tu jardín';

  @override
  String get permissionsTitle => 'Crecer juntos';

  @override
  String get permissionsSubtitle =>
      'Permite que Botanica cuide tus plantas sin problemas, o elige cuando estés listo.';

  @override
  String get permNotificationsTitle => 'Recordatorios Suaves';

  @override
  String get permNotificationsBody => 'Para que ninguno de los dos pase sed.';

  @override
  String get notificationsSoftAskTitle => 'No olvides el día de riego';

  @override
  String get notificationsSoftAskBody =>
      'Botanica envía recordatorios tranquilos a la hora que prefieras, para que cada planta reciba cuidado antes de decaer.';

  @override
  String get permLocationTitle => 'Conocimiento del Clima';

  @override
  String get permLocationBody =>
      'Cuidado adaptado exactamente a tu clima local.';

  @override
  String get permCameraTitle => 'Diario Visual';

  @override
  String get permCameraBody =>
      'Captura el crecimiento e identifica plantas con un vistazo.';

  @override
  String get permLocationServicesOff =>
      'Los servicios de ubicación están desactivados.';

  @override
  String get permStatusEnabled => 'Activado';

  @override
  String get permStatusNotEnabled => 'No activado';

  @override
  String get permStatusLimited => 'Limitado';

  @override
  String get permStatusProvisional => 'Provisional';

  @override
  String get permStatusRestricted => 'Restringido';

  @override
  String get permStatusBlocked => 'Bloqueado';

  @override
  String get permActionEnable => 'Activar';

  @override
  String get permActionOpenSettings => 'Abrir ajustes';

  @override
  String get permissionsEnableAll => 'Activar todo';

  @override
  String get permissionsNotNow => 'Ahora no';

  @override
  String get permissionsPrivacyNote =>
      'Botanica solo lo pide cuando lo necesitas — puedes cambiarlo más tarde en Perfil.';

  @override
  String get gardenTitle => 'Jardín';

  @override
  String get gardenTodayCardTitle => 'Hoy';

  @override
  String get gardenGreetingMorning => 'Buenos días';

  @override
  String get gardenGreetingAfternoon => 'Buenas tardes';

  @override
  String get gardenGreetingEvening => 'Buenas noches';

  @override
  String get gardenLoadError => 'No se pudieron cargar las plantas.';

  @override
  String gardenTasksDueToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas',
      one: '1 tarea',
      zero: 'Sin tareas',
    );
    return '$_temp0';
  }

  @override
  String get gardenAllCaughtUp => '¡Todo al día! Tus plantas están felices.';

  @override
  String allDoneQuietRunway(int days) {
    return 'Nada pendiente en $days días';
  }

  @override
  String allDoneTomorrowPreview(int count, String plants) {
    return 'Mañana · $count tareas para $plants';
  }

  @override
  String get gardenVacationBanner => 'Modo vacaciones — recordatorios pausados';

  @override
  String get gardenWeeklySummaryTitle => 'Esta semana';

  @override
  String gardenWeeklyCareActions(int count) {
    return '$count acciones de cuidado';
  }

  @override
  String gardenWeeklyWatered(int count) {
    return '$count regados';
  }

  @override
  String gardenWeeklyFertilized(int count) {
    return '$count fertilizados';
  }

  @override
  String gardenCareStreakChip(int days) {
    return 'Racha de $days días';
  }

  @override
  String gardenStreakAtRisk(int days) {
    return 'Tu racha de $days días termina hoy — ¡cuida una planta para mantenerla!';
  }

  @override
  String gardenWeatherChip(
      String condition, int temp, String unit, int humidity) {
    return '$condition · $temp°$unit · $humidity%';
  }

  @override
  String get weatherClear => 'Despejado';

  @override
  String get weatherPartlyCloudy => 'Parcialmente nublado';

  @override
  String get weatherCloudy => 'Nublado';

  @override
  String get weatherFog => 'Niebla';

  @override
  String get weatherDrizzle => 'Llovizna';

  @override
  String get weatherRain => 'Lluvia';

  @override
  String get weatherSnow => 'Nieve';

  @override
  String get weatherThunder => 'Tormenta';

  @override
  String get weatherUnknown => 'Tiempo';

  @override
  String get weatherTipRainy =>
      'Lluvia afuera — no riegues las plantas de exterior hoy';

  @override
  String get weatherTipStormy =>
      'Tormenta — lleva las plantas sensibles al interior';

  @override
  String get weatherTipExtremeHeat =>
      'Calor extremo — revisa la humedad del suelo y rocía las hojas';

  @override
  String get weatherTipHotSunny =>
      'Caluroso y soleado — riega temprano por la mañana o al atardecer';

  @override
  String get weatherTipNearFreezing =>
      'Cerca de congelarse — protege las plantas sensibles a las heladas';

  @override
  String get weatherTipSnow =>
      'Se espera nieve — mueve las macetas exteriores a un refugio';

  @override
  String get weatherTipCool => 'Día fresco — reduce la frecuencia de riego';

  @override
  String get weatherTipLowHumidity =>
      'Aire seco hoy — rocía las plantas tropicales o agrúpalas';

  @override
  String get weatherTipHighHumidity =>
      'Humedad alta — no rocíes y vigila los hongos';

  @override
  String get seasonalTipSpring =>
      'La primavera está aquí — hora de fertilizar y trasplantar si es necesario';

  @override
  String get seasonalTipSummer =>
      'El calor del verano significa regar con más frecuencia';

  @override
  String get seasonalTipAutumn =>
      'Otoño — reduce la fertilización mientras las plantas ralentizan su crecimiento';

  @override
  String get seasonalTipWinter =>
      'Invierno — la mayoría de plantas necesitan menos agua y nada de fertilizante';

  @override
  String get gardenQuickWatered => 'Regado';

  @override
  String get gardenQuickSnooze => 'Posponer';

  @override
  String get gardenQuickLogCare => 'Registrar cuidado';

  @override
  String get gardenQuickLogDone => '¡Registrado!';

  @override
  String get gardenViewDetails => 'Ver detalles';

  @override
  String get tasksSnoozeOneHour => '1 hora';

  @override
  String get tasksSnoozeThreeHours => '3 horas';

  @override
  String get tasksSnoozeTomorrow => 'Mañana';

  @override
  String get tasksSnoozeTomorrowMorning => 'Mañana por la mañana';

  @override
  String get tasksSnoozeWeekend => 'Este fin de semana';

  @override
  String get tasksSnoozeCustomTime => 'Hora personalizada';

  @override
  String get gardenQuickAddPlant => 'Añadir planta';

  @override
  String get gardenRoomsTitle => 'Habitaciones';

  @override
  String get gardenRoomsAll => 'Todas las habitaciones';

  @override
  String get gardenToggleCardMode => 'Alternar modo de tarjeta';

  @override
  String get gardenToggleViewMode => 'Alternar modo de vista';

  @override
  String gardenRoomPlantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plantas',
      one: '1 planta',
    );
    return '$_temp0';
  }

  @override
  String profilePlantsInGarden(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plantas en tu jardín',
      one: '1 planta en tu jardín',
    );
    return '$_temp0';
  }

  @override
  String get discoverInYourGarden => 'en tu jardín';

  @override
  String get gardenRoomsWaterAll => 'Regar todo';

  @override
  String get gardenRoomsSnoozeAll => 'Posponer todo';

  @override
  String gardenRoomsWateredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'plantas',
      one: 'planta',
    );
    return 'Regadas $count $_temp0 en la habitación';
  }

  @override
  String gardenRoomsSnoozedCount(int count) {
    return 'Se pospusieron $count tareas';
  }

  @override
  String get gardenEmptyTitle => 'Empieza tu jardín';

  @override
  String get gardenEmptyBody =>
      'Añade tu primera planta para un plan de cuidados a medida y tareas diarias.';

  @override
  String get gardenEmptyCta => 'Añadir primera planta';

  @override
  String get gardenAddPlantFab => 'Añadir planta';

  @override
  String get addPlantTitle => 'Añadir planta';

  @override
  String get addPlantMethodScan => 'Escanear';

  @override
  String get addPlantMethodLibrary => 'Desde la biblioteca';

  @override
  String get addPlantMethodManual => 'Entrada manual';

  @override
  String get addPlantScanTitle => 'Escanea tu planta';

  @override
  String get addPlantScanBody =>
      'Captura la hoja y la planta completa para mejores resultados.';

  @override
  String get addPlantScanButton => 'Escanear ahora';

  @override
  String get addPlantLibraryTitle => 'Elige una planta';

  @override
  String get addPlantManualTitle => 'Cuéntanos sobre ella';

  @override
  String get addPlantConfirmTitle => 'Confirmar detalles';

  @override
  String get addPlantFieldNickname => 'Apodo';

  @override
  String get addPlantFieldRoom => 'Habitación';

  @override
  String get addPlantDefaultRoomLivingRoom => 'Sala de estar';

  @override
  String get addPlantDefaultSpeciesUnknown => 'Desconocido';

  @override
  String get addPlantFieldEnvironment => 'Entorno';

  @override
  String get addPlantEnvIndoor => 'Interior';

  @override
  String get addPlantEnvBalcony => 'Balcón';

  @override
  String get addPlantEnvOutdoor => 'Exterior';

  @override
  String get addPlantReminderTime => 'Hora del recordatorio';

  @override
  String get addPlantReminderMorning => 'Mañana';

  @override
  String get addPlantReminderEvening => 'Tarde';

  @override
  String get addPlantReminderCustom => 'Personalizado';

  @override
  String get addPlantSaveButton => 'Guardar en Jardín';

  @override
  String get plantDetailOverview => 'Resumen';

  @override
  String get plantDetailCare => 'Cuidados';

  @override
  String get plantDetailJournal => 'Diario';

  @override
  String get plantDetailLogs => 'Registro';

  @override
  String get plantDetailLogsEmptyTitle => 'Sin registros de cuidado';

  @override
  String get plantDetailLogsEmptyBody =>
      'Completa una tarea de riego o cuidado y aparecerá aquí.';

  @override
  String get tasksEmptySoon => 'Nada pendiente pronto. ¡Todo al día!';

  @override
  String get tasksEmptyWatch =>
      'No hay tareas de vigilancia. Tu jardín descansa.';

  @override
  String get plantDetailWaterNow => 'Regar ahora';

  @override
  String get plantDetailAddPhoto => 'Añadir foto';

  @override
  String get plantDetailAddNote => 'Añadir nota';

  @override
  String get plantDetailMissingTitle => 'Planta no disponible';

  @override
  String get plantDetailMissingBody =>
      'No se encuentra esta planta. Es posible que se haya eliminado.';

  @override
  String get plantDetailMissingCta => 'Volver al jardín';

  @override
  String plantDetailNextWateringInDays(int days) {
    return 'Próximo riego en $days días';
  }

  @override
  String plantDetailCaringForDays(int days) {
    return 'Cuidando por $days días';
  }

  @override
  String get plantDetailEnvironmentImpactTitle => 'Impacto del entorno';

  @override
  String plantDetailEnvironmentImpactBaseAdjusted(int base, int adjusted) {
    return 'Base: $base días · Ajustado: $adjusted días';
  }

  @override
  String get plantDetailEnvironmentStable =>
      'Condiciones estables — sin ajustes hoy.';

  @override
  String get plantDetailDrynessLow => 'Sequedad baja (se seca más lento)';

  @override
  String get plantDetailDrynessBalanced => 'Sequedad equilibrada';

  @override
  String get plantDetailDrynessHigh => 'Sequedad alta (se seca más rápido)';

  @override
  String get plantDetailCareWaterBody =>
      'El próximo riego se calcula desde un intervalo base y se ajusta por humedad, temperatura y estación.';

  @override
  String get plantDetailCareLightBody =>
      'La luz brillante e indirecta es un buen punto de partida para muchas plantas.';

  @override
  String get plantDetailCareTempTitle => 'Temperatura';

  @override
  String get plantDetailCareTempBody =>
      'Evita corrientes frías repentinas. La calidez estable ayuda a un crecimiento predecible.';

  @override
  String get plantDetailJournalDesignNote =>
      'Aquí están diseñados el overlay de encuadre y el comparador; conecta cámara/galería después.';

  @override
  String get plantDetailJournalIntro =>
      'Un timeline suave de fotos y notas: tu diario de la planta.';

  @override
  String get journalSectionPhotos => 'Fotos';

  @override
  String get diarySectionTitle => 'Diario';

  @override
  String get diaryEmptyBody =>
      'Aún no hay notas. Añade una para recordar los cambios.';

  @override
  String get diaryAddEntryTitle => 'Nueva entrada';

  @override
  String get diaryAddEntryHint => 'Escribe lo que notaste hoy…';

  @override
  String get diaryAddEntryButton => 'Añadir nota';

  @override
  String get diaryEntryTitle => 'Entrada del diario';

  @override
  String get diaryEntrySaved => 'Guardado en el diario.';

  @override
  String get diaryEditEntryTitle => 'Editar entrada';

  @override
  String get diaryEditConfirmTitle => '¿Guardar cambios?';

  @override
  String get diaryEditConfirmBody =>
      'Actualiza esta entrada del diario con tus cambios.';

  @override
  String get diaryEntryUpdated => 'Entrada del diario actualizada.';

  @override
  String get diaryEntryDeleted => 'Entrada del diario eliminada.';

  @override
  String get diaryEntryDeleteTitle => '¿Eliminar entrada del diario?';

  @override
  String get diaryEntryDeleteBody =>
      'Esto elimina la entrada de la línea de tiempo. Puedes deshacerlo justo después.';

  @override
  String get diaryPromptGrowingWell => 'Creciendo bien';

  @override
  String get diaryPromptNewLeaf => 'Nueva hoja';

  @override
  String get diaryPromptStruggling => 'Con dificultad';

  @override
  String get diaryPromptRepotted => 'Trasplantada';

  @override
  String get diaryPromptBlooming => 'Floreciendo';

  @override
  String get journalEntryActions => 'Acciones de la entrada';

  @override
  String get journalShareCardTitle => 'Tarjeta para compartir';

  @override
  String get journalShareCardText => 'Hecho con Botanica';

  @override
  String get journalShareFailed => 'No se pudo compartir. Inténtalo de nuevo.';

  @override
  String get journalAddPhotoTitle => 'Añadir foto';

  @override
  String get journalAddPhotoCamera => 'Cámara';

  @override
  String get journalAddPhotoCameraBody =>
      'Captura una foto nueva con un overlay fantasma de la anterior.';

  @override
  String get journalAddPhotoGallery => 'Galería';

  @override
  String get journalAddPhotoGalleryBody => 'Elige una foto de tu biblioteca.';

  @override
  String get journalCaptureTitle => 'Capturar';

  @override
  String get journalCaptureTip =>
      'Llena el encuadre e intenta igualar la foto anterior para comparar mejor.';

  @override
  String get journalFlash => 'Flash';

  @override
  String get journalCameraPermissionNeeded =>
      'Se necesita permiso de cámara para capturar fotos.';

  @override
  String get journalPhotosPermissionNeeded =>
      'Se necesita permiso de fotos para elegir imágenes.';

  @override
  String get journalPhotoSaved => 'Guardado en el diario.';

  @override
  String get journalPhotoDeleted => 'Foto eliminada.';

  @override
  String get journalPhotoDeleteTitle => '¿Eliminar foto?';

  @override
  String get journalPhotoDeleteBody =>
      'Esto elimina la foto del diario de esta planta y del almacenamiento local. Puedes deshacerlo justo después.';

  @override
  String get journalEmptyBody =>
      'Aún no hay fotos. Añade una para comenzar la línea de tiempo.';

  @override
  String get journalPhotoTitle => 'Foto del diario';

  @override
  String get journalPhotoNoNote => 'Sin nota';

  @override
  String get journalAddNoteTitle => 'Añadir nota';

  @override
  String get journalAddNoteHint => 'Opcional: hoja nueva, trasplante, etc.';

  @override
  String get journalCompareTitle => 'Comparar';

  @override
  String get journalCompareHint =>
      'Arrastra a izquierda/derecha para comparar.';

  @override
  String get journalPhotoUnavailable => 'Foto no disponible';

  @override
  String get journalOverlayStrength => 'Intensidad de superposición';

  @override
  String get journalPreviousPhoto => 'Foto anterior';

  @override
  String get journalLimitedPhotosAccess =>
      'El acceso a fotos seleccionadas está activado. Puedes elegir fotos visibles o cambiar el acceso en Ajustes de iOS.';

  @override
  String journalPhotoMeta(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get scanTitle => 'Escanear';

  @override
  String get scanTryAgain => 'Reintentar';

  @override
  String get scanCaptureTitle => 'Escanea tu planta';

  @override
  String get scanCaptureTip =>
      'Captura la hoja y la planta completa para mejores resultados.';

  @override
  String get scanCameraPermissionNeeded =>
      'Se necesita permiso de cámara para escanear plantas.';

  @override
  String get scanCameraPermissionTitle => 'Acceso a la cámara';

  @override
  String get scanCameraPermissionBody =>
      'Usa la cámara para un escaneo rápido o explora la biblioteca sin conceder acceso.';

  @override
  String get scanUseCamera => 'Usar cámara';

  @override
  String get scanProcessingBody => 'Identificando tu planta…';

  @override
  String get scanChooseCandidate => 'Elige una coincidencia';

  @override
  String get scanRefineTitle => '¿No estás seguro? Refina los resultados';

  @override
  String get scanRefineHelper =>
      'Responde una pregunta rápida para acotar la lista.';

  @override
  String get scanRefineFallbackNote =>
      'Aún no hay coincidencias exactas para estos filtros; mostramos los resultados más cercanos.';

  @override
  String get scanConfidenceGuide =>
      'La confianza es solo una guía: compara la forma y las etiquetas de cuidado antes de añadir.';

  @override
  String get scanConfidenceStrongLabel => 'Alta confianza';

  @override
  String get scanConfidenceStrongBody =>
      'Se parece bastante a la planta capturada.';

  @override
  String get scanConfidenceLikelyLabel => 'Confianza moderada';

  @override
  String get scanConfidenceLikelyBody =>
      'Compara los detalles antes de añadir.';

  @override
  String get scanConfidencePossibleLabel =>
      'Baja confianza — prueba otro ángulo';

  @override
  String get scanConfidencePossibleBody =>
      'Es solo una suposición; captura otra vista si puedes.';

  @override
  String get scanRefineFlowering => '¿Está floreciendo?';

  @override
  String get scanRefineIndoorOutdoor => '¿Interior o exterior?';

  @override
  String get scanRefineSucculent => '¿Tipo suculenta?';

  @override
  String get scanRefinePetSafe => 'Apto para mascotas';

  @override
  String get scanRefineEasy => 'Fácil';

  @override
  String get scanRefineLowLight => 'Poca luz';

  @override
  String get scanAddToGarden => 'Añadir al jardín';

  @override
  String get scanBrowseLibrary => 'Explorar biblioteca';

  @override
  String get scanTakingLongerTitle => 'Está tardando más de lo esperado';

  @override
  String get scanTakingLongerBody =>
      'El escaneo no terminó a tiempo. Inténtalo de nuevo o elige una planta manualmente.';

  @override
  String get scanNoResultTitle => 'No se pudo identificar esta planta';

  @override
  String get scanNoResultBody =>
      'Prueba otro ángulo con detalle de la hoja o explora la biblioteca.';

  @override
  String get scanDeterministicNote =>
      'Modo demo: resultados deterministas sin conexión. Conecta Kindwise/Gemini después.';

  @override
  String get tasksTitle => 'Tareas';

  @override
  String get tasksTabToday => 'Hoy';

  @override
  String get tasksTabSoon => 'Pronto';

  @override
  String get tasksTabWatch => 'Vigilancia';

  @override
  String get tasksCalendarToggle => 'Calendario';

  @override
  String get tasksSeasonalTipsTitle => 'Consejos de temporada';

  @override
  String get tipSpringRepot =>
      'Primavera: trasplanta si las raíces están apretadas y el crecimiento ha vuelto.';

  @override
  String get tipSpringFertilize =>
      'Primavera: reanuda un abonado suave cuando empiece el crecimiento nuevo.';

  @override
  String get tipSummerWaterMore =>
      'Verano: revisa la humedad más a menudo; con el calor se seca rápido.';

  @override
  String get tipSummerShadeOutdoor =>
      'Verano: protege las plantas de balcón/exterior del sol fuerte del mediodía.';

  @override
  String get tipAutumnReduceWater =>
      'Otoño: reduce el riego a medida que baja la luz y el crecimiento.';

  @override
  String get tipAutumnBringIndoor =>
      'Otoño: mete las plantas sensibles antes de las noches frías.';

  @override
  String get tipWinterReduceFertilize =>
      'Invierno: abona menos y riega menos; el crecimiento se ralentiza.';

  @override
  String get tipWinterLowLight =>
      'Invierno: acércalas a la luz o usa luz de crecimiento para evitar que se estiren.';

  @override
  String tasksSnoozedUntil(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Pospuesto hasta $dateString';
  }

  @override
  String get tasksSkipped => 'Saltado';

  @override
  String get discoverTitle => 'Descubrir';

  @override
  String get discoverPlantOfTheDay => 'Planta del día';

  @override
  String get discoverSearchHint => 'Busca plantas, guías y consejos';

  @override
  String get discoverNoResultsTitle => 'Sin resultados';

  @override
  String get discoverNoResultsBody =>
      'Prueba con otro nombre o busca por el nombre científico.';

  @override
  String get discoverSectionCurated => 'Plantas destacadas';

  @override
  String get discoverSectionLibrary => 'Biblioteca de plantas';

  @override
  String get discoverSectionGuides => 'Guías';

  @override
  String get discoverFilters => 'Filtros';

  @override
  String get discoverFilterPetSafe => 'Apto para mascotas';

  @override
  String get discoverFilterDifficulty => 'Dificultad';

  @override
  String get discoverFilterLight => 'Luz';

  @override
  String get discoverTagPetSafe => 'Apto para mascotas';

  @override
  String get discoverTagToxic => 'Tóxico';

  @override
  String get discoverGuideWateringTitle => 'Riego básico';

  @override
  String get discoverGuideWateringBody =>
      'Aprende a leer la humedad del sustrato y evita el exceso de riego.';

  @override
  String get discoverGuideSoilTitle => 'Sustrato y drenaje';

  @override
  String get discoverGuideSoilBody =>
      'Por qué las mezclas aireadas reducen la pudrición de raíces.';

  @override
  String get discoverGuidePestTitle => 'Lista de plagas';

  @override
  String get discoverGuidePestBody =>
      'Una rutina semanal rápida para detectar problemas temprano.';

  @override
  String get discoverAddFavorite => 'Añadir a favoritos';

  @override
  String get discoverRemoveFavorite => 'Quitar de favoritos';

  @override
  String get speciesDetailHistory => 'Historia';

  @override
  String get speciesDetailHabit => 'Hábito de crecimiento';

  @override
  String get speciesDetailCareAtAGlance => 'Cuidados de un vistazo';

  @override
  String speciesDetailWaterEvery(int days) {
    return 'Riega cada $days días';
  }

  @override
  String speciesDetailFertilizeEvery(int days) {
    return 'Fertiliza cada $days días';
  }

  @override
  String speciesDetailMistEvery(int days) {
    return 'Rocía cada $days días';
  }

  @override
  String get speciesDetailDetails => 'Detalles';

  @override
  String get speciesDetailOrigin => 'Origen';

  @override
  String get speciesDetailToxicity => 'Toxicidad';

  @override
  String get speciesDetailGrowth => 'Crecimiento';

  @override
  String get speciesDetailMatureSize => 'Tamaño adulto';

  @override
  String get speciesDetailSizeHeight => 'Altura';

  @override
  String get speciesDetailSizeSpread => 'Extensión';

  @override
  String get speciesDetailSizeVineLength => 'Longitud de la enredadera';

  @override
  String speciesDetailRangeCm(int min, int max) {
    return '$min–$max cm';
  }

  @override
  String speciesDetailCmValue(int value) {
    return '$value cm';
  }

  @override
  String get speciesDetailUnknown => 'Desconocido';

  @override
  String get growthRateSlow => 'Lento';

  @override
  String get growthRateModerate => 'Moderado';

  @override
  String get growthRateFast => 'Rápido';

  @override
  String get growthRateUnknown => 'Desconocido';

  @override
  String get growthFormUpright => 'Erguido';

  @override
  String get growthFormTrailing => 'Colgante';

  @override
  String get growthFormClimbing => 'Trepador';

  @override
  String get growthFormRosette => 'Roseta';

  @override
  String get growthFormTreeLike => 'Tipo árbol';

  @override
  String get growthFormClumping => 'En matas';

  @override
  String get growthFormEpiphytic => 'Epífito';

  @override
  String get growthFormSucculent => 'Suculento';

  @override
  String get growthFormFern => 'Helecho';

  @override
  String get growthFormOrchid => 'Orquídea';

  @override
  String get growthFormOther => 'Otro';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Media';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get lightBrightDirect => 'Luz directa brillante';

  @override
  String get lightBrightIndirect => 'Luz brillante indirecta';

  @override
  String get lightMediumIndirect => 'Luz indirecta media';

  @override
  String get lightLowToBrightIndirect => 'De poca a brillante indirecta';

  @override
  String get lightLowToBright => 'De poca a brillante';

  @override
  String get dailyTitle => 'Flor del Día';

  @override
  String get dailyReveal => 'Revelar';

  @override
  String get dailyRevealHintTap => 'Toca para revelar';

  @override
  String get dailyRevealHintSlide => 'Desliza para revelar';

  @override
  String get dailyRevealHintHold => 'Mantén pulsado para revelar';

  @override
  String get dailyRevealHintPull => 'Tira para revelar';

  @override
  String get dailyRevealHintStamp => 'Sella para revelar';

  @override
  String get dailyRevealHintFlip => 'Voltea para revelar';

  @override
  String get dailyRevealHintTrace => 'Traza para revelar';

  @override
  String get dailyInfoTitle => 'Acerca de Flor del día';

  @override
  String get dailyInfoIntro =>
      'Flor del día es un ritual tranquilo que cambia una vez al día.';

  @override
  String get dailyInfoModeWesternZodiac =>
      'Zodiaco occidental: se basa en tu fecha de nacimiento o en el signo que elijas.';

  @override
  String get dailyInfoModeTarot =>
      'Tarot: se elige robando cuatro cartas y seleccionando una.';

  @override
  String dailyInfoModeAuto(String mode) {
    return '$mode usa un sorteo diario basado en la fecha de hoy y tu clave personal.';
  }

  @override
  String get dailyInfoModeJustFlower =>
      'Solo flor es el ritual más simple. Toca para revelar una flor personalizada.';

  @override
  String dailyInfoHowToReveal(String hint) {
    return 'Cómo revelar: $hint';
  }

  @override
  String get dailyInfoChangeMode => 'Cambiar modo';

  @override
  String get dailySave => 'Guardar';

  @override
  String get dailyShare => 'Compartir';

  @override
  String get dailyCareToday => 'Cuidado de hoy';

  @override
  String get dailyHowToAppreciate => 'Cómo apreciar hoy';

  @override
  String get dailyAiNoteTitle => 'Nota de Botanica';

  @override
  String get plantCareAiTipTitle => 'Consejo de cuidado de hoy';

  @override
  String get dailyModeMissingTitle => 'Elige tu modo diario';

  @override
  String get dailyModeMissingBody =>
      'Elige una tradición (tarot, almanaque, runas…) y Botanica personalizará tu Flor del Día.';

  @override
  String get dailyModeMissingCta => 'Elegir modo';

  @override
  String get dailyTarotNotDrawn => 'Sacar cartas';

  @override
  String get dailyTarotDrawTitle => 'Tirada de tarot';

  @override
  String get dailyTarotDrawBody =>
      'Se reparten 4 cartas. Elige 1 — y Botanica revela la flor de hoy.';

  @override
  String get dailyTarotDrawCta => 'Repartir 4 cartas';

  @override
  String get dailyTarotCardLabel => 'Elige';

  @override
  String get dailyDeterministicNote =>
      'La Flor del Día es determinista: mismo día + idioma + modo + perfil → misma carta (ideal para compartir).';

  @override
  String get dailyContentUnavailableTitle => 'Flor del Día no disponible';

  @override
  String get dailyContentUnavailableBody =>
      'Botanica no pudo cargar el contenido de hoy. Vuelve a intentarlo.';

  @override
  String get dailyProfileMissingTitle => 'Completa tu perfil';

  @override
  String get dailyProfileMissingBody =>
      'Configura una clave personal en Perfil (una semilla corta o tu fecha de nacimiento) para personalizar la Flor del Día.';

  @override
  String get dailyProfileMissingBodyZodiac =>
      'Configura tu fecha de nacimiento (o elige tu signo) en Perfil para personalizar la Flor del Día.';

  @override
  String get dailyProfileMissingCta => 'Configurar';

  @override
  String get careKeyLight => 'Luz';

  @override
  String get careKeyWater => 'Riego';

  @override
  String get careKeyTemperature => 'Temperatura';

  @override
  String get careKeyPetSafety => 'Seguridad para mascotas';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileSectionPreferences => 'Preferencias';

  @override
  String get profileSectionPermissions => 'Permisos';

  @override
  String get profileSectionData => 'Datos';

  @override
  String get profileSectionAbout => 'Acerca de';

  @override
  String get storageHealthTitle => 'Estado del almacenamiento';

  @override
  String get storageHealthSubtitle =>
      'Revisa los medios del diario y limpia archivos temporales.';

  @override
  String get storageJournalPhotos => 'Fotos del diario';

  @override
  String get storageUsed => 'Almacenamiento usado';

  @override
  String get storagePhotoFiles => 'Archivos de foto';

  @override
  String get storageJournalEntries => 'Entradas del diario';

  @override
  String get storagePhotoEntries => 'Entradas con foto';

  @override
  String get storageMissingPhotos => 'Fotos faltantes';

  @override
  String get storageCacheTitle => 'Caché temporal';

  @override
  String get storageCacheBody =>
      'Borra tarjetas compartidas generadas y archivos temporales sin eliminar tus fotos del diario.';

  @override
  String get storageClearCache => 'Limpiar caché';

  @override
  String get storageCacheCleared => 'Caché temporal limpiada.';

  @override
  String storageFileCount(int count) {
    return '$count archivos';
  }

  @override
  String storageEntryCount(int count) {
    return '$count entradas';
  }

  @override
  String get exportDataTitle => 'Exportar datos de cuidado';

  @override
  String get exportDataSubtitle =>
      'Guarda tus plantas e historial de cuidado como archivo JSON.';

  @override
  String get exportDataSuccess => 'Datos de cuidado exportados correctamente.';

  @override
  String get exportDataEmpty =>
      'No hay datos para exportar — añade algunas plantas primero.';

  @override
  String get profileLanguage => 'Idioma';

  @override
  String get profileUnits => 'Unidades';

  @override
  String get profileHemisphereTitle => 'Hemisferio';

  @override
  String get profileHemisphereBody =>
      'Se usa para ajustes estacionales de cuidado (invierno vs verano).';

  @override
  String get hemisphereNorthern => 'Norte';

  @override
  String get hemisphereSouthern => 'Sur';

  @override
  String get profileBeliefMode => 'Modo diario';

  @override
  String get profileDailyProfileTitle => 'Personalización diaria';

  @override
  String profileDailyProfileBody(String mode) {
    return 'Elige tu clave personal para $mode.';
  }

  @override
  String get profileBirthdateTitle => 'Fecha de nacimiento';

  @override
  String get profileBirthdateBody =>
      'Se usa para personalizar el zodiaco y el almanaque.';

  @override
  String get profileDailySeedTitle => 'Clave personal';

  @override
  String get profileDailySeedBody =>
      'Una semilla corta (como tu apodo) que personaliza la Flor del Día sin cambiar el modo.';

  @override
  String get profileDailySeedHint => 'p. ej., Aster';

  @override
  String get profileDailyProfileUseBirthdate => 'Usar fecha';

  @override
  String get profileDailyProfileNotSet => 'Sin configurar';

  @override
  String get profileDailyProfileKeySet => 'Clave establecida';

  @override
  String get profileDailyProfileNotNeeded =>
      'No se necesita información personal.';

  @override
  String get profileDailyProfilePickModeFirst =>
      'Primero elige tu modo diario y luego configúralo aquí.';

  @override
  String get profileDailyProfileTarotSubtitle => 'Sacar en Diario';

  @override
  String get profileDailyProfileAutoSubtitle => 'Auto (fecha)';

  @override
  String get profileDailyProfileTarotBody =>
      'El modo Tarot es un ritual diario. Abre Diario, reparte cuatro cartas y elige una — y se revela la flor de hoy.';

  @override
  String get profileDailyProfileTarotCta => 'Abrir Diario';

  @override
  String profileDailyProfileAutoBody(String mode) {
    return '$mode usa una selección diaria basada en la fecha de hoy y tu clave personal.';
  }

  @override
  String get profileDailyProfileLocalDefault => 'Usa tu idioma';

  @override
  String get profileLocalTraditionKeyTitle => 'Clave cultural';

  @override
  String get profileLocalTraditionKeyHint => 'p. ej.: global, china, japan…';

  @override
  String get profilePhotos => 'Fotos';

  @override
  String get profileNotifications => 'Notificaciones';

  @override
  String get profileLocation => 'Ubicación';

  @override
  String get profilePrivacy => 'Privacidad';

  @override
  String get profileBackup => 'Copia de seguridad';

  @override
  String get profileCredits => 'Créditos';

  @override
  String get profileDynamicColorTitle => 'Color dinámico';

  @override
  String get profileDynamicColorBody =>
      'Usa la paleta del dispositivo cuando esté disponible.';

  @override
  String get vacationModeTitle => 'Modo vacaciones';

  @override
  String get vacationModeOff =>
      'Pausa todos los recordatorios mientras estás fuera.';

  @override
  String vacationModeActiveUntil(String date) {
    return 'Activo hasta $date';
  }

  @override
  String get vacationModeEnd => 'Finalizar modo vacaciones';

  @override
  String get vacationModePickDate => 'Fecha de regreso';

  @override
  String get profileAiInsightsTitle => 'Ideas con IA';

  @override
  String get profileAiInsightsBody =>
      'Notas sutiles en pantalla que personalizan tu ritual de la Flor del Día.';

  @override
  String get profileAiKeyTitle => 'Clave API de IA';

  @override
  String get profileAiKeyConfigured => 'Configurada';

  @override
  String get profileAiKeyNotSet => 'Sin configurar';

  @override
  String get profileAiKeyNotRequired => 'No se necesita';

  @override
  String get profileAiKeySheetBody =>
      'Se guarda de forma segura en este dispositivo. Se usa solo para generar notas breves en pantalla, en tu idioma seleccionado.';

  @override
  String get profileAiKeyNotRequiredBody =>
      'Esta versión está configurada para usar un proxy sin autenticación, por lo que no necesitas una clave API.';

  @override
  String get profileAiKeySheetHint => 'Pega tu clave API';

  @override
  String get profileAiKeySaved => 'Clave de IA guardada.';

  @override
  String get profileAiKeyCleared => 'Clave de IA eliminada.';

  @override
  String get profileLanguageSystem => 'Sistema';

  @override
  String get creditsTitle => 'Créditos';

  @override
  String get creditsOpenSource => 'Código abierto';

  @override
  String get creditsFlutterCommunity => 'Referencias de la comunidad Flutter';

  @override
  String get creditsUiInspiration => 'Inspiración UI';

  @override
  String get creditsPlaceholderNote =>
      'Nota: este proyecto usa PNG blancos de marcador de posición — reemplaza los assets más adelante por fotografías/ilustraciones reales.';

  @override
  String get unitsCelsius => 'Celsius (°C)';

  @override
  String get unitsFahrenheit => 'Fahrenheit (°F)';

  @override
  String get beliefModeWesternZodiac => 'Zodiaco occidental';

  @override
  String get beliefModeChineseZodiac => 'Zodiaco chino';

  @override
  String get beliefModeTarot => 'Tarot';

  @override
  String get beliefModeLocalTraditions => 'Tradiciones locales';

  @override
  String get beliefModeJustFlower => 'Solo una flor';

  @override
  String get beliefModeNotSet => 'Sin configurar';

  @override
  String get beliefModeAlmanac => 'Almanaque';

  @override
  String get beliefModeOmikuji => 'Omikuji japonés';

  @override
  String get beliefModeRunes => 'Runas nórdicas';

  @override
  String get beliefModeOgham => 'Ogham celta';

  @override
  String get zodiacAries => 'Aries';

  @override
  String get zodiacTaurus => 'Tauro';

  @override
  String get zodiacGemini => 'Géminis';

  @override
  String get zodiacCancer => 'Cáncer';

  @override
  String get zodiacLeo => 'Leo';

  @override
  String get zodiacVirgo => 'Virgo';

  @override
  String get zodiacLibra => 'Libra';

  @override
  String get zodiacScorpio => 'Escorpio';

  @override
  String get zodiacSagittarius => 'Sagitario';

  @override
  String get zodiacCapricorn => 'Capricornio';

  @override
  String get zodiacAquarius => 'Acuario';

  @override
  String get zodiacPisces => 'Piscis';

  @override
  String get chineseZodiacRat => 'Rata';

  @override
  String get chineseZodiacOx => 'Buey';

  @override
  String get chineseZodiacTiger => 'Tigre';

  @override
  String get chineseZodiacRabbit => 'Conejo';

  @override
  String get chineseZodiacDragon => 'Dragón';

  @override
  String get chineseZodiacSnake => 'Serpiente';

  @override
  String get chineseZodiacHorse => 'Caballo';

  @override
  String get chineseZodiacGoat => 'Cabra';

  @override
  String get chineseZodiacMonkey => 'Mono';

  @override
  String get chineseZodiacRooster => 'Gallo';

  @override
  String get chineseZodiacDog => 'Perro';

  @override
  String get chineseZodiacPig => 'Cerdo';

  @override
  String get tarotTheFool => 'El Loco';

  @override
  String get tarotTheMagician => 'El Mago';

  @override
  String get tarotTheHighPriestess => 'La Sacerdotisa';

  @override
  String get tarotTheEmpress => 'La Emperatriz';

  @override
  String get tarotTheEmperor => 'El Emperador';

  @override
  String get tarotTheHierophant => 'El Hierofante';

  @override
  String get tarotTheLovers => 'Los Enamorados';

  @override
  String get tarotTheChariot => 'El Carro';

  @override
  String get tarotStrength => 'La Fuerza';

  @override
  String get tarotTheHermit => 'El Ermitaño';

  @override
  String get tarotWheelOfFortune => 'La Rueda de la Fortuna';

  @override
  String get tarotJustice => 'La Justicia';

  @override
  String get tarotTheHangedMan => 'El Colgado';

  @override
  String get tarotDeath => 'La Muerte';

  @override
  String get tarotTemperance => 'La Templanza';

  @override
  String get tarotTheDevil => 'El Diablo';

  @override
  String get tarotTheTower => 'La Torre';

  @override
  String get tarotTheStar => 'La Estrella';

  @override
  String get tarotTheMoon => 'La Luna';

  @override
  String get tarotTheSun => 'El Sol';

  @override
  String get tarotJudgement => 'El Juicio';

  @override
  String get tarotTheWorld => 'El Mundo';

  @override
  String get omikujiDaikichi => 'Gran suerte (Daikichi)';

  @override
  String get omikujiChukichi => 'Suerte media (Chūkichi)';

  @override
  String get omikujiShokichi => 'Pequeña suerte (Shōkichi)';

  @override
  String get omikujiKichi => 'Suerte (Kichi)';

  @override
  String get omikujiHankichi => 'Media suerte (Hankichi)';

  @override
  String get omikujiSuekichi => 'Suerte futura (Suekichi)';

  @override
  String get omikujiKyo => 'Mala suerte (Kyō)';

  @override
  String get omikujiDaikyo => 'Muy mala suerte (Daikyō)';

  @override
  String get taskTypeWater => 'Regar';

  @override
  String get taskTypeFertilize => 'Fertilizar';

  @override
  String get taskTypeMist => 'Rociar';

  @override
  String get taskTypeRotate => 'Girar';

  @override
  String get taskTypePrune => 'Podar';

  @override
  String get taskTypeRepot => 'Trasplantar';

  @override
  String get taskTypeCheckPests => 'Revisar plagas';

  @override
  String get taskTypeWipeLeaves => 'Limpiar hojas';

  @override
  String get taskTypeSunlightAdjustment => 'Ajustar luz';

  @override
  String notificationsTaskTitle(String plant, String task) {
    return '$plant · $task';
  }

  @override
  String notificationsTaskBodyRoom(String room) {
    return 'En $room';
  }

  @override
  String get notificationsTaskBodyNoRoom =>
      'Abre Botanica para marcarlo como hecho.';

  @override
  String notificationWaterTitle(String plant) {
    return 'Hora de regar $plant';
  }

  @override
  String notificationFertilizeTitle(String plant) {
    return 'Fertiliza $plant hoy';
  }

  @override
  String notificationMistTitle(String plant) {
    return 'A $plant le encantaría un poco de humedad';
  }

  @override
  String notificationRotateTitle(String plant) {
    return 'Dale a $plant un cuarto de vuelta';
  }

  @override
  String notificationPruneTitle(String plant) {
    return '$plant está lista para podar';
  }

  @override
  String notificationWaterTitle2(String plant) {
    return '¡$plant tiene sed!';
  }

  @override
  String notificationWaterTitle3(String plant) {
    return 'Tu $plant necesita agua';
  }

  @override
  String notificationFertilizeTitle2(String plant) {
    return '$plant necesita nutrientes';
  }

  @override
  String notificationFertilizeTitle3(String plant) {
    return 'Hora de alimentar a $plant';
  }

  @override
  String notificationMistTitle2(String plant) {
    return '¿Un poco de humedad para $plant?';
  }

  @override
  String notificationMistTitle3(String plant) {
    return 'Hora de rociar a $plant';
  }

  @override
  String notificationRotateTitle2(String plant) {
    return 'Rota $plant para un crecimiento uniforme';
  }

  @override
  String notificationRotateTitle3(String plant) {
    return '$plant necesita un giro hoy';
  }

  @override
  String notificationPruneTitle2(String plant) {
    return 'Hora de arreglar $plant';
  }

  @override
  String notificationPruneTitle3(String plant) {
    return '$plant necesita una poda';
  }

  @override
  String get notificationDailySummaryTitle =>
      '¡Buenos días, amante de las plantas!';

  @override
  String notificationDailySummaryBody(int count) {
    return 'Tienes $count tareas de cuidado hoy. ¡Tus plantas cuentan contigo!';
  }

  @override
  String get reasonHumidityLow =>
      'Humedad baja → el sustrato se seca más rápido';

  @override
  String get reasonHumidityHigh =>
      'Humedad alta → el sustrato permanece húmedo más tiempo';

  @override
  String get reasonHot => 'Temperatura alta → más evaporación';

  @override
  String get reasonSpring => 'Primavera → vuelve el crecimiento';

  @override
  String get reasonSummer => 'Verano → más transpiración';

  @override
  String get reasonAutumn => 'Otoño → el crecimiento se ralentiza';

  @override
  String get reasonWinter => 'Invierno → crecimiento más lento';

  @override
  String get reasonOutdoor => 'Modo exterior → mayor peso del pronóstico';

  @override
  String get reasonIndoor => 'Modo interior → se asumen condiciones estables';

  @override
  String get envLightLow => 'Luz baja';

  @override
  String get envLightMedium => 'Luz media';

  @override
  String get envLightHigh => 'Luz alta';

  @override
  String get envLabelTemp => 'Temp.';

  @override
  String get envLabelHumidity => 'Humedad';

  @override
  String get envLabelLight => 'Luz';

  @override
  String get gardenWellnessTitle => 'Bienestar del jardín';

  @override
  String get gardenWellnessSubtitle =>
      'Ver puntuación, plantas clave y carga de cuidado';

  @override
  String get gardenWellnessEmptyTitle => 'Aún no hay plantas';

  @override
  String get gardenFilterEmptyTitle =>
      'No hay plantas que coincidan con este filtro.';

  @override
  String get gardenWellnessEmptyBody =>
      'Añade tu primera planta para desbloquear el bienestar del jardín.';

  @override
  String get gardenWellnessOverallScore => 'Puntuación general';

  @override
  String gardenWellnessOverdueChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vencidas',
      one: '1 vencida',
    );
    return '$_temp0';
  }

  @override
  String get gardenWellnessStatPlants => 'Plantas';

  @override
  String get gardenWellnessStatRecentCare => 'Cuidado reciente';

  @override
  String get gardenWellnessStatAtRisk => 'En riesgo';

  @override
  String get gardenWellnessStatPunctuality => 'A tiempo';

  @override
  String get gardenWellnessStatWeeklyActive => 'Semanas activas';

  @override
  String get gardenWellnessStatBestStreak => 'Mejor racha';

  @override
  String get gardenWellnessMomentumIncreasing => 'Impulso en alza';

  @override
  String get gardenWellnessMomentumDecreasing => 'Impulso bajando';

  @override
  String get gardenWellnessRoomPulseTitle => 'Pulso por habitación';

  @override
  String gardenWellnessRoomPulseSummary(int plantCount, int overdueCount) {
    return '$plantCount plantas · $overdueCount vencidas';
  }

  @override
  String get gardenWellnessRoomPulseStable => 'estable';

  @override
  String gardenWellnessRoomPulseAtRisk(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count en riesgo',
      one: '1 en riesgo',
    );
    return '$_temp0';
  }

  @override
  String get gardenWellnessPrioritiesTitle => 'Prioridades de hoy';

  @override
  String get gardenWellnessFocusPlantsTitle => 'Plantas clave';

  @override
  String get gardenWellnessScoreLabel => 'puntuación';

  @override
  String get gardenWellnessScoreFlourishing => 'Floreciendo';

  @override
  String get gardenWellnessScoreSteady => 'Estable';

  @override
  String get gardenWellnessScoreNeedsLittleCare =>
      'Necesita un poco de cuidado';

  @override
  String get gardenWellnessScoreNeedsAttention => 'Necesita atención';

  @override
  String gardenWellnessFocusReasonOverdueAndNoLog(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas vencidas · Sin registro reciente',
      one: '1 tarea vencida · Sin registro reciente',
    );
    return '$_temp0';
  }

  @override
  String gardenWellnessFocusReasonOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas vencidas',
      one: '1 tarea vencida',
    );
    return '$_temp0';
  }

  @override
  String get gardenWellnessFocusReasonNoLog =>
      'Sin registro reciente en 14 días';

  @override
  String get gardenWellnessFocusReasonSteady => 'Se ve estable';

  @override
  String gardenWellnessPriorityAttentionTitle(String plantName) {
    return 'Revisa $plantName';
  }

  @override
  String gardenWellnessPriorityAttentionBodyOverdueAndNoLog(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas vencidas y sin registro reciente.',
      one: '1 tarea vencida y sin registro reciente.',
    );
    return '$_temp0';
  }

  @override
  String gardenWellnessPriorityAttentionBodyOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas vencidas necesitan atención.',
      one: '1 tarea vencida necesita atención.',
    );
    return '$_temp0';
  }

  @override
  String get gardenWellnessPriorityAttentionBodyNoLog =>
      'No hay registro reciente en los últimos 14 días.';

  @override
  String get gardenWellnessPriorityAttentionBodyCheckIn =>
      'Esta planta necesita una revisión rápida.';

  @override
  String get gardenWellnessPriorityDueTodayTitle => 'Mantén el día en orden';

  @override
  String gardenWellnessPriorityDueTodayBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas vencen hoy.',
      one: '1 tarea vence hoy.',
    );
    return '$_temp0';
  }

  @override
  String get gardenWellnessPriorityRefreshHistoryTitle =>
      'Actualiza el historial de cuidado';

  @override
  String gardenWellnessPriorityRefreshHistoryBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plantas no tienen un registro reciente.',
      one: '1 planta no tiene un registro reciente.',
    );
    return '$_temp0';
  }

  @override
  String get gardenWellnessPriorityCalmTitle => 'Disfruta la calma';

  @override
  String get gardenWellnessPriorityCalmBody =>
      'No hay asuntos urgentes hoy — tu jardín se ve estable.';

  @override
  String get gardenWellnessRoomUnassigned => 'Sin asignar';

  @override
  String get editPlantTitle => 'Editar planta';

  @override
  String get editPlantSaveButton => 'Guardar cambios';

  @override
  String get plantDetailMenuEdit => 'Editar planta';

  @override
  String get plantDetailMenuArchive => 'Archivar planta';

  @override
  String get plantDetailMenuDelete => 'Eliminar planta';

  @override
  String archivePlantTitle(String plantName) {
    return '¿Archivar $plantName?';
  }

  @override
  String get archivePlantBody =>
      'Las plantas archivadas se ocultan de su jardín pero conservan su historial.';

  @override
  String get archivePlantConfirm => 'Archivar';

  @override
  String deletePlantTitle(String plantName) {
    return '¿Eliminar $plantName?';
  }

  @override
  String get deletePlantBody =>
      'Esto elimina permanentemente la planta y todo su historial. No se puede deshacer.';

  @override
  String get deletePlantConfirm => 'Eliminar';

  @override
  String restorePlantTitle(String plantName) {
    return '¿Restaurar $plantName?';
  }

  @override
  String get restorePlantBody =>
      'Esto devolverá la planta a su jardín y reanudará su cuidado.';

  @override
  String get restorePlantConfirm => 'Restaurar';

  @override
  String get gardenStatusArchived => 'Archivada';

  @override
  String get gardenSortTitle => 'Ordenar por';

  @override
  String get gardenFilterArchived => 'Archivadas';

  @override
  String get gardenSortCare => 'Necesita cuidado';

  @override
  String get gardenSortName => 'Nombre';

  @override
  String get gardenSortNewest => 'Más recientes';

  @override
  String get gardenSortHealth => 'Puntuación de salud';

  @override
  String get gardenSortRoom => 'Habitación';

  @override
  String get gardenSortSpecies => 'Especie';

  @override
  String get gardenSortNeedsCare => 'Necesita cuidado';

  @override
  String get gardenFilterAll => 'Todas';

  @override
  String get gardenFilterHealthy => 'Sanas';

  @override
  String get gardenFilterNeedsCare => 'Necesitan cuidado';

  @override
  String get gardenSearchHint => 'Buscar plantas...';

  @override
  String archivePlantSuccess(String nickname) {
    return 'Planta archivada exitosamente';
  }

  @override
  String restorePlantSuccess(String nickname) {
    return 'Planta restaurada exitosamente';
  }

  @override
  String deletePlantSuccess(String nickname) {
    return 'Planta eliminada exitosamente';
  }

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String streakMilestoneTitle(int days) {
    return '¡Hito de $days días!';
  }

  @override
  String get streakMilestoneBody7 =>
      'Una semana completa de cuidado. Tu jardín te lo agradece.';

  @override
  String get streakMilestoneBody30 =>
      '30 días seguidos. Estás creando un hábito real.';

  @override
  String get streakMilestoneBody90 =>
      '¡90 días! Tus plantas nunca han estado más felices.';

  @override
  String get streakMilestoneBody365 =>
      'Un año completo de cuidado. Eres una leyenda.';

  @override
  String get streakMilestoneDismiss => '¡Sigue así!';

  @override
  String timeCapsuleTitle(int days) {
    return 'Hace $days días';
  }

  @override
  String timeCapsuleBody(String plant, int days) {
    return 'Tomaste esta foto de $plant hace $days días. Mira cuánto han crecido juntos.';
  }

  @override
  String get rescueResetTitle => 'Bienvenido de vuelta';

  @override
  String rescueResetBody(int streak, int days) {
    return 'Tenías una racha de $streak días. Han pasado $days días — sin culpa, solo un nuevo comienzo cuando estés listo.';
  }

  @override
  String get rescueResetWaterNow => 'Regar una planta ahora';

  @override
  String get rescueResetFreshStart => 'Empezar de nuevo';

  @override
  String streakSavedSnackbar(String plant, int days) {
    return '¡Racha salvada! $plant cuidada · ritmo de $days días intacto';
  }

  @override
  String get plantPulseTitle => 'Hora de un chequeo';

  @override
  String plantPulseBody(String plant, int days) {
    return '$plant no tiene foto desde hace $days días. Mira cuánto ha crecido.';
  }

  @override
  String get plantPulseCta => 'Tomar una foto';

  @override
  String get plantJourneyTitle => 'Vuestro camino juntos';

  @override
  String plantJourneyNextMilestone(String milestone) {
    return 'Siguiente: $milestone';
  }

  @override
  String get plantJourneyMilestoneFirstWater => 'Primer riego';

  @override
  String get plantJourneyMilestoneFirstPhoto => 'Primera foto';

  @override
  String get plantJourneyMilestone7Days => '7 días juntos';

  @override
  String get plantJourneyMilestoneFirstFertilize => 'Primera fertilización';

  @override
  String get plantJourneyMilestone10Waters => '10 riegos';

  @override
  String get plantJourneyMilestone30Days => '30 días juntos';

  @override
  String get plantJourneyMilestone25Waters => '25 riegos';

  @override
  String get plantJourneyMilestone100Days => '100 días juntos';

  @override
  String get plantJourneyMilestone365Days => '1 año juntos';

  @override
  String get gardenerTypeTitle => 'Tu tipo de jardinero';

  @override
  String get gardenerTypeDevoted => 'El Devoto';

  @override
  String get gardenerTypeDevotedDesc =>
      '30+ días de cuidado ininterrumpido. Tus plantas te adoran.';

  @override
  String get gardenerTypeConsistent => 'El Constante';

  @override
  String get gardenerTypeConsistentDesc =>
      'Más del 80% de tareas a tiempo. Fiable como un reloj.';

  @override
  String get gardenerTypeExplorer => 'El Explorador';

  @override
  String get gardenerTypeExplorerDesc =>
      '5+ especies en tu colección. Un verdadero explorador botánico.';

  @override
  String get gardenerTypePhotographer => 'El Fotógrafo';

  @override
  String get gardenerTypePhotographerDesc =>
      '10+ fotos documentando el crecimiento. Cada hoja cuenta una historia.';

  @override
  String get gardenerTypeNurturer => 'El Cuidador';

  @override
  String get gardenerTypeNurturerDesc =>
      '50+ acciones de cuidado. Tu jardín prospera con tu atención.';

  @override
  String get gardenerTypeBudding => 'Jardinero en Ciernes';

  @override
  String get gardenerTypeBuddingDesc =>
      'Todo experto fue principiante. ¡Sigue creciendo!';

  @override
  String get whispererTierSeedling => 'Semilla';

  @override
  String get whispererTierSprout => 'Brote';

  @override
  String get whispererTierGardener => 'Jardinero';

  @override
  String get whispererTierBotanist => 'Botánico';

  @override
  String get whispererTierWhisperer => 'Susurrador de Plantas';

  @override
  String whispererNextLevel(int xp) {
    return '$xp XP para el siguiente nivel';
  }

  @override
  String careCombo(int count) {
    return '¡${count}x combo!';
  }

  @override
  String careComboStreak(int count) {
    return '¡${count}x combo! ¡Estás imparable!';
  }

  @override
  String get lastCareWater => 'Regado';

  @override
  String get lastCareFertilize => 'Fertilizado';

  @override
  String get lastCarePhoto => 'Foto';

  @override
  String lastCareDaysAgo(int days) {
    return 'hace ${days}d';
  }

  @override
  String get lastCareToday => 'Hoy';

  @override
  String get lastCareNever => '—';

  @override
  String careConfidenceOnSchedule(int days) {
    return 'Justo a tiempo (promedio $days días)';
  }

  @override
  String get careConfidenceEarly =>
      'Un poco pronto — el suelo podría estar húmedo';

  @override
  String get careConfidenceLate => 'Un poco tarde, pero no pasa nada';

  @override
  String get gardenMoodThriving => 'Floreciendo';

  @override
  String get gardenMoodHappy => 'Feliz';

  @override
  String get gardenMoodNeedsLove => 'Necesita amor';

  @override
  String get gardenMoodThirsty => 'Sediento';

  @override
  String get plantDetailLogsSparklineTitle => 'Actividad 14 días';

  @override
  String plantDetailLogsSparklineCount(int count) {
    return '$count acciones';
  }

  @override
  String get commonToday => 'Hoy';

  @override
  String get calendarHeatmapTitle => 'Actividad 12 semanas';

  @override
  String get profileStatsTotalCare => 'Cuidado total';

  @override
  String get profileStatsWatered => 'Regado';

  @override
  String get profileStatsFertilized => 'Fertilizado';

  @override
  String profileStatsActions(int count) {
    return '$count';
  }

  @override
  String get profileCareScore => 'Puntuación de cuidado';

  @override
  String profileCareScoreLabel(int percent) {
    return '$percent%';
  }

  @override
  String get profileCareScoreSubtitle => 'Tasa de puntualidad en 30 días';

  @override
  String get weeklyRecapTitle => 'Tu semana en resumen';

  @override
  String get weeklyRecapActiveDays => 'Días activos';

  @override
  String weeklyRecapSummary(int actions, int days) {
    return '$actions acciones de cuidado en $days días activos esta semana';
  }

  @override
  String get weeklyRecapDismiss => '¡Buen trabajo!';

  @override
  String weeklyRecapBestDay(String day) {
    return 'Mejor día: $day';
  }

  @override
  String weeklyRecapStreak(int days) {
    return 'Racha: $days días';
  }

  @override
  String get gardenAllTasksDoneTitle => '¡Todo listo por hoy!';

  @override
  String get gardenAllTasksDoneBody =>
      'Todas tus plantas están felices. Disfruta el resto del día.';

  @override
  String get gardenAllDoneBody2 => 'Tus amigos verdes prosperan gracias a ti.';

  @override
  String get gardenAllDoneBody3 => 'La constancia es el secreto. Lo tienes.';

  @override
  String get gardenAllDoneBody4 => 'Otro día de excelente cuidado vegetal.';

  @override
  String get gardenAllDoneBody5 => 'Tus plantas se fortalecen cada día más.';

  @override
  String profileLongestStreak(int days) {
    return 'Mejor: $days días';
  }

  @override
  String profileGardenAge(int days) {
    return 'Jardín: $days días';
  }

  @override
  String gardenNewPersonalBest(int days) {
    return '¡Nuevo récord! Racha de $days días';
  }

  @override
  String gardenTomorrowPreview(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'plantas necesitan',
      one: 'planta necesita',
    );
    return 'Mañana: $count $_temp0 cuidado';
  }

  @override
  String get gardenMotivation7DayStreak =>
      'Vas muy bien — sigue con el impulso.';

  @override
  String get gardenMotivation30DayStreak =>
      'Un mes de constancia. Tus plantas prosperan.';

  @override
  String get gardenMotivationWelcomeBack =>
      'Bienvenido de vuelta — tus plantas te extrañaron.';

  @override
  String get gardenMotivationBigGarden =>
      'Una colección floreciente. Lo tienes controlado.';

  @override
  String get gardenMotivationMorning =>
      'Un gran día para revisar a tus amigos verdes.';

  @override
  String get gardenMotivationEvening =>
      'Relájate con un vistazo rápido al jardín.';

  @override
  String get gardenMotivationAllDoneToday =>
      'Todo al día — tus plantas están felices.';

  @override
  String get gardenMotivationNewPlant =>
      'Tu planta más nueva se está adaptando bien.';

  @override
  String gardenStreakFreezeUsed(int days) {
    return '¡Congelación de racha usada! Tu racha de $days días está a salvo.';
  }

  @override
  String gardenStreakFreezeEarned(int count) {
    return '¡Ganaste una congelación de racha! ($count disponibles)';
  }

  @override
  String profileStreakFreezes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count congelaciones',
      one: '1 congelación',
    );
    return '$_temp0 disponibles';
  }

  @override
  String gardenPlantMilestone(int count) {
    return '¡$count plantas en tu jardín! Tu colección crece hermosamente.';
  }

  @override
  String get streakShareTitle => 'Comparte tu racha';

  @override
  String streakShareCardDays(int days) {
    return 'Racha de $days días';
  }

  @override
  String get streakShareCardSubtitle => 'Cuidando mis plantas cada día';

  @override
  String get streakShareButton => 'Compartir';

  @override
  String get plantLastWateredToday => 'Regada hoy';

  @override
  String get plantLastWateredYesterday => 'Regada ayer';

  @override
  String plantLastWateredDaysAgo(int days) {
    return 'Regada hace $days días';
  }

  @override
  String get plantNeverWatered => 'Aún no regada';

  @override
  String plantAgeLabel(int days) {
    return '$days días en tu jardín';
  }

  @override
  String plantAnniversaryLabel(int years) {
    return '¡$years año de aniversario!';
  }

  @override
  String get careLogAddNote => 'Añadir nota';

  @override
  String get careLogEditNote => 'Editar nota';

  @override
  String get careLogNoteHint => '¿Cómo se veía? ¿Algo que recordar?';

  @override
  String get careLogNoteSaved => 'Nota guardada';

  @override
  String get careStatsTitle => 'Patrones de cuidado';

  @override
  String get careStatsTotalWaterings => 'Riegos';

  @override
  String get careStatsAvgInterval => 'Intervalo prom.';

  @override
  String careStatsAvgDays(int days) {
    return '${days}d';
  }

  @override
  String get careStatsTotalActions => 'Total acciones';

  @override
  String get careStatsConsistency => 'Consistencia';

  @override
  String get careStatsTip =>
      'Intenta configurar un recordatorio recurrente para crear una rutina estable.';

  @override
  String get gardenForecastTitle => 'Próximos 7 días';

  @override
  String gardenForecastTaskCount(int count) {
    return '$count tareas';
  }

  @override
  String gardenForecastBusyDay(String day) {
    return 'Más ocupado: $day';
  }

  @override
  String get gardenForecastEmpty => 'Sin tareas programadas esta semana';

  @override
  String get gardenForecastToday => 'Hoy';

  @override
  String get gardenForecastTomorrow => 'Mañana';

  @override
  String get wellnessHeatmapTitle => 'Actividad de cuidado';

  @override
  String get wellnessHeatmapSubtitle => 'Últimas 12 semanas';

  @override
  String wellnessHeatmapActions(int count) {
    return '$count acciones';
  }

  @override
  String gardenWeeklyTrendUp(int diff) {
    return '+$diff vs semana pasada';
  }

  @override
  String gardenWeeklyTrendDown(int diff) {
    return '$diff vs semana pasada';
  }

  @override
  String get gardenWeeklyTrendSame => 'Igual que la semana pasada';

  @override
  String gardenWeeklyMostActiveDay(String day) {
    return 'Más activo: $day';
  }

  @override
  String get achievementsTitle => 'Logros';

  @override
  String achievementsUnlocked(int count, int total) {
    return '$count/$total desbloqueados';
  }

  @override
  String get achievementFirstPlant => 'Primer brote';

  @override
  String get achievementFirstPlantDesc => 'Añade tu primera planta';

  @override
  String get achievementFivePlants => 'Colección creciente';

  @override
  String get achievementFivePlantsDesc => 'Llega a 5 plantas en tu jardín';

  @override
  String get achievementTenPlants => 'Entusiasta de plantas';

  @override
  String get achievementTenPlantsDesc => 'Llega a 10 plantas en tu jardín';

  @override
  String get achievementTwentyPlants => 'Maestro de la jungla';

  @override
  String get achievementTwentyPlantsDesc => 'Cultiva 20 plantas';

  @override
  String get achievementFirstCare => 'Primera gota';

  @override
  String get achievementFirstCareDesc => 'Completa tu primera tarea de cuidado';

  @override
  String get achievementFiftyCares => 'Cuidador dedicado';

  @override
  String get achievementFiftyCaresDesc => 'Completa 50 tareas de cuidado';

  @override
  String get achievementHundredCares => 'Pulgar verde';

  @override
  String get achievementHundredCaresDesc => 'Completa 100 tareas de cuidado';

  @override
  String get achievementFiveHundredCares => 'Susurrador de plantas';

  @override
  String get achievementFiveHundredCaresDesc =>
      'Completa 500 tareas de cuidado';

  @override
  String get achievementWeekStreak => 'Guerrero semanal';

  @override
  String get achievementWeekStreakDesc => 'Mantén una racha de 7 días';

  @override
  String get achievementMonthStreak => 'Devoción mensual';

  @override
  String get achievementMonthStreakDesc => 'Mantén una racha de 30 días';

  @override
  String get achievementYearStreak => 'Jardinero legendario';

  @override
  String get achievementYearStreakDesc => 'Mantén una racha de 365 días';

  @override
  String get achievementFirstPhoto => 'Instantánea';

  @override
  String get achievementFirstPhotoDesc => 'Toma tu primera foto de planta';

  @override
  String get achievementTenPhotos => 'Diario fotográfico';

  @override
  String get achievementTenPhotosDesc => 'Captura 10 fotos de plantas';

  @override
  String get achievementFiftyPhotos => 'Narrador visual';

  @override
  String get achievementFiftyPhotosDesc => 'Captura 50 fotos de plantas';

  @override
  String get achievementThreeRooms => 'Explorador de habitaciones';

  @override
  String get achievementThreeRoomsDesc => 'Coloca plantas en 3 habitaciones';

  @override
  String get achievementFiveRooms => 'Jardín en toda la casa';

  @override
  String get achievementFiveRoomsDesc => 'Coloca plantas en 5 habitaciones';

  @override
  String get achievementDiverseCarer => 'Jardinero renacentista';

  @override
  String get achievementDiverseCarerDesc =>
      'Realiza 5 tipos de cuidado diferentes';

  @override
  String get tasksCompleteAll => 'Completar todo';

  @override
  String tasksCompleteAllDone(int count) {
    return '$count tareas completadas';
  }

  @override
  String get tasksStreakAtRiskTitle => 'Racha en riesgo!';

  @override
  String tasksStreakAtRiskBody(int days) {
    return 'Tu racha de $days dias termina esta noche. Completa una tarea para mantenerla.';
  }

  @override
  String get plantMilestoneOneMonth => '¡1 mes juntos!';

  @override
  String get plantMilestoneThreeMonths => '¡3 meses juntos!';

  @override
  String get plantMilestoneSixMonths => '¡Medio año de cuidado!';

  @override
  String get plantMilestoneOneYear => '¡Aniversario de 1 año!';

  @override
  String get plantMilestoneTwoYears => '¡2 años de crecimiento!';

  @override
  String plantMilestoneSubtitle(String name, int days) {
    return 'Has cuidado de $name durante $days días';
  }

  @override
  String get seasonalTipTitle => 'Consejo estacional';

  @override
  String get seasonalTipSpringRepotTitle => 'Hora de trasplantar';

  @override
  String get seasonalTipSpringRepotBody =>
      'La primavera es el mejor momento para trasplantar. Las plantas entran en fase de crecimiento y se recuperan rápido del estrés.';

  @override
  String get seasonalTipSpringFertilizeTitle => 'Retoma el abono';

  @override
  String get seasonalTipSpringFertilizeBody =>
      'Empieza a fertilizar de nuevo con los días más largos. Comienza con media dosis y aumenta gradualmente.';

  @override
  String get seasonalTipSpringGrowthTitle => 'Observa el nuevo crecimiento';

  @override
  String get seasonalTipSpringGrowthBody =>
      'Tus plantas están despertando. Busca hojas nuevas, brotes y raíces — buen momento para fotos de progreso.';

  @override
  String get seasonalTipSpringWaterTitle => 'Aumenta el riego';

  @override
  String get seasonalTipSpringWaterBody =>
      'Con el crecimiento activo, tus plantas beberán más. Revisa la humedad del suelo con más frecuencia que en invierno.';

  @override
  String get seasonalTipSpringPestsTitle => 'Patrulla de plagas';

  @override
  String get seasonalTipSpringPestsBody =>
      'El clima cálido trae plagas. Inspecciona regularmente los brotes nuevos y el envés de las hojas.';

  @override
  String get seasonalTipSummerWaterTitle => 'Mantén la hidratación';

  @override
  String get seasonalTipSummerWaterBody =>
      'El calor y los días largos aceleran la evaporación. Riega profundamente y revisa el suelo más seguido.';

  @override
  String get seasonalTipSummerMistTitle => 'Aumenta la humedad';

  @override
  String get seasonalTipSummerMistBody =>
      'El aire acondicionado reseca el aire. Pulveriza las plantas tropicales o agrúpalas para crear un microclima húmedo.';

  @override
  String get seasonalTipSummerSunburnTitle => 'Cuidado con las quemaduras';

  @override
  String get seasonalTipSummerSunburnBody =>
      'El sol intenso del mediodía puede quemar las hojas. Aleja las plantas sensibles de ventanas orientadas al sur.';

  @override
  String get seasonalTipSummerOutdoorTitle => 'Tiempo al aire libre';

  @override
  String get seasonalTipSummerOutdoorBody =>
      'Muchas plantas de interior disfrutan unas vacaciones de verano al exterior. Aclimatálas gradualmente.';

  @override
  String get seasonalTipSummerPropagateTitle => 'Temporada de esquejes';

  @override
  String get seasonalTipSummerPropagateBody =>
      'El calor del verano y los días largos hacen ideal este momento para esquejes. La mayoría enraíza rápidamente.';

  @override
  String get seasonalTipAutumnWaterTitle => 'Reduce el riego';

  @override
  String get seasonalTipAutumnWaterBody =>
      'El crecimiento se ralentiza con los días más cortos. Deja secar más el sustrato entre riegos.';

  @override
  String get seasonalTipAutumnFertilizeTitle => 'Deja de abonar';

  @override
  String get seasonalTipAutumnFertilizeBody =>
      'La mayoría de plantas entrarán en reposo pronto. Deja de fertilizar para evitar acumulación de sales.';

  @override
  String get seasonalTipAutumnLightTitle => 'Persigue la luz';

  @override
  String get seasonalTipAutumnLightBody =>
      'Con el sol más bajo, acerca las plantas a las ventanas. Rótalas regularmente para una iluminación uniforme.';

  @override
  String get seasonalTipAutumnInsideTitle => 'Trae las plantas adentro';

  @override
  String get seasonalTipAutumnInsideBody =>
      'Si sacaste plantas en verano, mételas antes de que las noches bajen de 10°C.';

  @override
  String get seasonalTipAutumnCleanTitle => 'Día de limpieza';

  @override
  String get seasonalTipAutumnCleanBody =>
      'El polvo bloquea la luz. Limpia las hojas con un paño húmedo para una fotosíntesis eficiente en invierno.';

  @override
  String get seasonalTipWinterWaterTitle => 'Riega con moderación';

  @override
  String get seasonalTipWinterWaterBody =>
      'La mayoría de plantas necesitan mucha menos agua en invierno. El exceso de riego es el mayor peligro en reposo.';

  @override
  String get seasonalTipWinterHumidityTitle => 'Combate el aire seco';

  @override
  String get seasonalTipWinterHumidityBody =>
      'La calefacción reseca el aire dramáticamente. Usa un humidificador o bandejas con guijarros para las tropicales.';

  @override
  String get seasonalTipWinterDraftsTitle => 'Evita corrientes frías';

  @override
  String get seasonalTipWinterDraftsBody =>
      'Mantén las plantas lejos de ventanas con corrientes y puertas exteriores. Los cambios bruscos de temperatura las dañan.';

  @override
  String get seasonalTipWinterLightTitle => 'Maximiza la luz';

  @override
  String get seasonalTipWinterLightBody =>
      'Los días cortos reducen la fotosíntesis. Mueve las plantas a los puntos más luminosos o considera luces de cultivo.';

  @override
  String get seasonalTipWinterRestTitle => 'Déjalas descansar';

  @override
  String get seasonalTipWinterRestBody =>
      'El reposo es natural y saludable. No te preocupes por el crecimiento lento — están guardando energía para primavera.';

  @override
  String get healthBreakdownTitle => 'Puntuación de salud';

  @override
  String get healthBreakdownSubtitle =>
      'Estos factores contribuyen a la salud de esta planta';

  @override
  String healthBreakdownOverall(int score) {
    return 'Total: $score/100';
  }

  @override
  String get healthFactorOverdue => 'Puntualidad de tareas';

  @override
  String get healthFactorActivity => 'Actividad de cuidado reciente';

  @override
  String get healthFactorVariety => 'Variedad de cuidados';

  @override
  String get healthFactorConsistency => 'Consistencia del horario';

  @override
  String get coachingTitle => 'Coaching de cuidado';

  @override
  String get coachingLateWatererTitle => 'Ajusta tus recordatorios';

  @override
  String get coachingLateWatererBody =>
      'Sueles regar uno o dos días tarde. Intenta cambiar la hora del recordatorio a cuando estés libre.';

  @override
  String get coachingStreakAtRiskTitle => '¡Racha en riesgo!';

  @override
  String get coachingStreakAtRiskBody =>
      'No has cuidado ninguna planta hoy. Un riego rápido mantiene tu racha.';

  @override
  String get coachingNeglectedPlantTitle => 'Una planta te necesita';

  @override
  String get coachingNeglectedPlantBody =>
      'Una de tus plantas no ha recibido cuidados en más de 3 semanas. Échale un vistazo.';

  @override
  String get coachingImprovingTitle => '¡Estás mejorando!';

  @override
  String get coachingImprovingBody =>
      'Has sido más activo esta semana que la anterior. Mantén el impulso.';

  @override
  String get coachingConsistentTitle => 'Campeón de consistencia';

  @override
  String get coachingConsistentBody =>
      '9 de tus últimas 10 tareas se completaron a tiempo. Tus plantas prosperan.';

  @override
  String get coachingDiversifyTitle => 'Prueba algo nuevo';

  @override
  String get coachingDiversifyBody =>
      'Solo has estado regando últimamente. Considera nebulizar, rotar o fertilizar para plantas más sanas.';

  @override
  String get plantDetailNextWateringTomorrow => 'Mañana';

  @override
  String get plantDetailNextWateringToday => 'Hoy vence';

  @override
  String gardenStreakFreezeAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count congelaciones de racha disponibles',
      one: '1 congelación de racha disponible',
    );
    return '$_temp0';
  }

  @override
  String get commonDismiss => 'Cerrar';

  @override
  String get plantDetailHealthScore => 'Puntuación de salud';

  @override
  String get plantDetailExpandText => 'Expandir texto';

  @override
  String get plantDetailCollapseText => 'Contraer texto';

  @override
  String get gardenWateredToday => 'Regada hoy';

  @override
  String get gardenWateredYesterday => 'Regada ayer';

  @override
  String gardenWateredDaysAgo(int days) {
    return 'Regada hace $days días';
  }

  @override
  String get gardenNeverWatered => 'Aún no regada';

  @override
  String calendarHeatmapTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count acciones de cuidado',
      one: '1 acción de cuidado',
    );
    return '$_temp0';
  }

  @override
  String calendarHeatmapTooltipDetail(
      int waters, String fertSep, int fertilizes, String otherSep, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      waters,
      locale: localeName,
      other: '$waters riegos',
      one: '1 riego',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      fertilizes,
      locale: localeName,
      other: '$fertilizes fertilizaciones',
      one: '1 fertilización',
      zero: '',
    );
    String _temp2 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others otros',
      one: '1 otro',
      zero: '',
    );
    return '$_temp0$fertSep$_temp1$otherSep$_temp2';
  }

  @override
  String calendarDayCareCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros de cuidado',
      one: '1 registro de cuidado',
    );
    return '$_temp0';
  }

  @override
  String get exportDataConfirmTitle => '¿Exportar datos de cuidado?';

  @override
  String get exportDataConfirmBody =>
      'Se creará un archivo JSON con todas tus plantas, registros de cuidado y tareas.';

  @override
  String get exportDataConfirmAction => 'Exportar';

  @override
  String get gardenWaterAllOverdue => 'Regar todas las atrasadas';

  @override
  String gardenWaterAllOverdueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Regar $count plantas atrasadas',
      one: 'Regar 1 planta atrasada',
    );
    return '$_temp0';
  }

  @override
  String gardenWateredAllOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se regaron $count plantas atrasadas',
      one: 'Se regó 1 planta atrasada',
    );
    return '$_temp0';
  }

  @override
  String get plantOverviewNoCareStats =>
      'Riega tu planta varias veces para ver patrones de cuidado aquí.';

  @override
  String get plantOverviewNoAiInsights =>
      'Activa las sugerencias de IA en ajustes para obtener consejos personalizados.';

  @override
  String get plantOverviewNoTasksYet =>
      'Aún no hay tareas pendientes. Los horarios de cuidado aparecerán al crearse.';

  @override
  String get gardenHealthTrendUp => 'Mejorando';

  @override
  String get gardenHealthTrendDown => 'Bajando';

  @override
  String get gardenHealthTrendStable => 'Estable';

  @override
  String plantCareStreakLabel(int days) {
    return 'Racha de $days días';
  }

  @override
  String get tasksEmptySoonMotivation =>
      'Disfruta la calma. Tus plantas están prosperando.';

  @override
  String get manageCareTitle => 'Gestionar recordatorios';

  @override
  String manageCareSubtitle(int active, int disabled) {
    return '$active activos · $disabled desactivados';
  }

  @override
  String get manageCareSpeciesDefault => 'Predeterminado de especie';

  @override
  String get manageCareEnabledByYou => 'Activado por ti';

  @override
  String get manageCareDisabledByYou => 'Desactivado por ti';

  @override
  String get manageCareButton => 'Gestionar';

  @override
  String manageCareDisableConfirm(String type) {
    return '¿Desactivar recordatorios de $type?';
  }

  @override
  String get manageCareEnabled => 'Activado';

  @override
  String get manageCareDisabled => 'Desactivado';

  @override
  String get growthEchoCompareTitle => 'Antes y ahora';

  @override
  String growthEchoCompareBody(String plant, int days) {
    return '$plant tiene $days días de crecimiento para comparar.';
  }

  @override
  String get growthEchoCaptureTitle => 'Registro de crecimiento';

  @override
  String growthEchoCaptureBody(int days, String plant) {
    return 'Han pasado $days días desde la última foto de $plant.';
  }

  @override
  String get commonProblemsTitle => 'Problemas comunes';

  @override
  String commonProblemsSubtitle(String plant) {
    return 'Vigila estos problemas con tu $plant';
  }

  @override
  String perfectWeekTitle(int count) {
    return 'Semana perfecta $count!';
  }

  @override
  String get perfectWeekBody =>
      'Todas las tareas completadas a tiempo durante 7 dias seguidos. Tus plantas prosperan gracias a ti.';

  @override
  String perfectWeekBodyRepeat(int count) {
    return '$count semanas perfectas seguidas. Estas en otra liga.';
  }

  @override
  String get perfectWeekDismiss => 'A por la siguiente!';

  @override
  String get growthTimelineTitle => 'Linea de crecimiento';

  @override
  String get growthTimelineEmpty => 'Toma fotos para seguir el crecimiento';

  @override
  String notificationStreakProtectionTitle(int days) {
    return 'Tu racha de $days dias esta en riesgo!';
  }

  @override
  String get notificationStreakProtectionBody =>
      'Completa una tarea de cuidado antes de medianoche para mantenerla.';

  @override
  String get careRhythmTitle => 'Tu ritmo de cuidado';

  @override
  String careRhythmAvgInterval(int days) {
    return 'Promedio ${days}d entre riegos';
  }

  @override
  String get careRhythmConsistent => 'Muy consistente';

  @override
  String get careRhythmImproving => 'Cada vez más consistente';

  @override
  String get careRhythmNoData => 'Riega unas veces más para ver tu ritmo';

  @override
  String get plantMoodThriving => '¡Floreciendo! 🌱';

  @override
  String get plantMoodHappy => 'Muy bien';

  @override
  String get plantMoodOkay => 'Bien';

  @override
  String get plantMoodThirsty => 'Tengo sed…';

  @override
  String get plantMoodNeglected => 'Te extraño…';

  @override
  String get plantMoodNewHere => '¡Recién plantada!';

  @override
  String plantAnniversaryTitle(String plant) {
    return '¡Feliz aniversario, $plant!';
  }

  @override
  String get plantAnniversaryBody30 =>
      'Un mes juntos. Estás construyendo algo hermoso.';

  @override
  String get plantAnniversaryBody90 =>
      'Tres meses de cuidado. Tu dedicación se nota.';

  @override
  String get plantAnniversaryBody180 =>
      '¡Medio año! Esta planta prospera gracias a ti.';

  @override
  String get plantAnniversaryBody365 => 'Un año juntos. Qué viaje increíble.';

  @override
  String get plantAnniversaryDismiss => '¡Por muchos más!';

  @override
  String insightRhythmShift(String plant, String oldDays, String newDays) {
    return 'El ritmo de riego de $plant cambió de cada $oldDays a $newDays días';
  }

  @override
  String insightFavoriteCareDay(String percent, String day) {
    return '$percent% de tu cuidado ocurre los $day — tu día de jardín';
  }

  @override
  String insightActiveTime(String period, String percent) {
    return 'Eres un padre de plantas de $period — $percent% del cuidado es entonces';
  }

  @override
  String insightMostLovedPlant(String plant, String actions) {
    return '$plant recibió más atención este mes — $actions acciones';
  }

  @override
  String insightQuietThenBusy(String quietDays, String taskCount) {
    return '$quietDays días tranquilos, luego $taskCount tareas por venir';
  }

  @override
  String insightCareAcceleration(String thisWeek, String lastWeek) {
    return 'Estás en racha — $thisWeek acciones esta semana vs $lastWeek la anterior';
  }

  @override
  String insightGardenGrowing(String total, String recent) {
    return 'Tu jardín crece — $total plantas ahora, $recent añadidas recientemente';
  }

  @override
  String insightSeasonalActivity(
      String direction, String thisMonth, String lastMonth) {
    return 'Cambio estacional: $direction activo este mes ($thisMonth) vs anterior ($lastMonth)';
  }

  @override
  String get insightSectionTitle => 'Inteligencia del Jardín';

  @override
  String quickCheckInTitle(String plant) {
    return '¿Cómo se ve $plant?';
  }

  @override
  String get quickCheckInSubtitle =>
      'Un vistazo rápido ayuda a seguir la salud de tu planta';

  @override
  String get quickCheckInThriving => 'Radiante';

  @override
  String get quickCheckInOkay => 'Bien';

  @override
  String get quickCheckInWorried => 'Preocupado';

  @override
  String get diversityTitle => 'Índice de Biodiversidad';

  @override
  String get diversitySpecies => 'Especies';

  @override
  String get diversityLightNeeds => 'Necesidades de luz';

  @override
  String get diversityDifficulty => 'Dificultad';

  @override
  String get diversityEnvironment => 'Entorno';

  @override
  String get diversitySuggestNewSpecies =>
      'Intenta añadir una especie diferente';

  @override
  String get diversitySuggestDifferentLight =>
      'Considera plantas con diferentes necesidades de luz';

  @override
  String get diversitySuggestVaryDifficulty =>
      'Mezcla plantas fáciles y difíciles';

  @override
  String get diversitySuggestOutdoor =>
      'Prueba una planta de exterior para más diversidad';

  @override
  String get diversitySuggestAddPlants =>
      'Añade más plantas para aumentar la diversidad';

  @override
  String get momentumTitle => 'Impulso del Jardín';

  @override
  String momentumTrending(String direction) {
    return 'Tendencia $direction';
  }

  @override
  String get momentumUp => 'al alza';

  @override
  String get momentumDown => 'a la baja';

  @override
  String get momentumSteady => 'estable';

  @override
  String get momentumStreak => 'Racha';

  @override
  String get momentumActivity => 'Actividad';

  @override
  String get momentumGrowth => 'Crecimiento';

  @override
  String get batchPlannerTitle => 'Horario de Riego';

  @override
  String batchPlannerEfficiency(int percent) {
    return '$percent% eficiente';
  }

  @override
  String batchPlannerDays(int count) {
    return '$count días de riego/semana';
  }

  @override
  String batchPlannerPlants(int count) {
    return '$count plantas';
  }

  @override
  String get careImpactTitle => 'Tu Impacto de Cuidado';

  @override
  String get careImpactWaterings => 'riegos';

  @override
  String get careImpactSaved => 'salvadas';

  @override
  String get careImpactTypes => 'tipos';

  @override
  String careImpactLongestCompanion(String name, int days) {
    return 'Compañera más larga: $name (${days}d)';
  }

  @override
  String careImpactAvgResponse(String hours) {
    return 'Respuesta promedio: ${hours}h';
  }

  @override
  String get gardenLegacyTitle => 'Legado del Jardín';

  @override
  String get gardenLegacyTotalCare => 'Acciones de cuidado totales';

  @override
  String get gardenLegacyLongestSurvivor => 'Mayor superviviente';

  @override
  String get gardenLegacyScore => 'Puntuación de legado';

  @override
  String roomCompatibilityTitle(String room) {
    return 'Compatibilidad de $room';
  }

  @override
  String roomCompatibilityPairings(int plants, int pairings) {
    return '$plants plantas, $pairings combinaciones';
  }

  @override
  String get wateringEfficiencyTitle => 'Eficiencia de riego';

  @override
  String wateringEfficiencyOptimal(int count, int total) {
    return '$count/$total óptimo';
  }

  @override
  String get careAutopilotTitle => 'Piloto automático';

  @override
  String careAutopilotUrgent(int count) {
    return '$count urgentes';
  }

  @override
  String get roomSuggestionsTitle => 'Sugerencias de sala';

  @override
  String roomSuggestionsMoves(int count) {
    return '$count cambios';
  }

  @override
  String get dailyFactTitle => '¿Sabías que?';

  @override
  String get seasonalTransitionTitle => 'Transición estacional';

  @override
  String seasonalTransitionWeeks(int weeks) {
    return 'en $weeks sem';
  }

  @override
  String get gardenInsightsTitle => 'Perspectivas del jardín';

  @override
  String get recommendedForYouTitle => 'Recomendado para ti';

  @override
  String recommendedGaps(String gaps) {
    return 'Vacíos: $gaps';
  }

  @override
  String get plantMemoryFirstPhoto => 'Primera foto';

  @override
  String get plantMemoryFirstCare => 'Primer cuidado';

  @override
  String get plantMemoryAnniversary => 'Aniversario';

  @override
  String get plantMemoryBusiestDay => 'Día más activo';

  @override
  String get plantMemoryLongestGap => 'Mayor pausa';

  @override
  String get plantMemoryComeback => 'Regreso';

  @override
  String careAutopilotMore(int count) {
    return '+$count sugerencias más';
  }

  @override
  String wateringEfficiencyMore(int count) {
    return '+$count más';
  }

  @override
  String seasonalTransitionMore(int count) {
    return '+$count tareas más';
  }

  @override
  String get gardenProgressTitle => 'Inteligencia del jardín';

  @override
  String gardenProgressUnlocked(int unlocked, int total) {
    return '$unlocked/$total';
  }

  @override
  String gardenProgressMilestonePlant(String feature) {
    return 'Añade 1 planta más para desbloquear $feature';
  }

  @override
  String gardenProgressMilestoneLogs(int count, String feature) {
    return 'Registra $count cuidados más para $feature';
  }

  @override
  String get transitionMoveIndoors => 'Mover al interior';

  @override
  String get transitionMoveOutdoors => 'Mover al exterior';

  @override
  String get transitionReduceWatering => 'Reducir riego';

  @override
  String get transitionIncreaseWatering => 'Aumentar riego';

  @override
  String get transitionStartFertilizing => 'Empezar a fertilizar';

  @override
  String get transitionStopFertilizing => 'Dejar de fertilizar';

  @override
  String get transitionIncreaseHumidity => 'Aumentar humedad';

  @override
  String get transitionProtectFromFrost => 'Proteger de heladas';

  @override
  String get transitionProvideShadeCover => 'Proporcionar sombra';

  @override
  String get transitionResumeNormalCare => 'Reanudar cuidado normal';

  @override
  String get dailyBriefingTitle => 'Resumen diario';

  @override
  String get dailyBriefingAllCaughtUp =>
      'Todo al día — ¡tu jardín está floreciendo!';

  @override
  String get weeklyInsightTitle => 'Perspectiva semanal';

  @override
  String get dailyChallengeTitle => 'Desafío diario';

  @override
  String get dailyChallengeAccept => 'Aceptar';

  @override
  String get communityChallengesTitle => 'Desafíos comunitarios';

  @override
  String get dailyRitualTitle => 'Ritual diario';

  @override
  String get achievementsRecent => 'Recientes';

  @override
  String get careEffectivenessTitle => 'Efectividad del cuidado';

  @override
  String get scheduleTuningTitle => 'Ajuste de horario';

  @override
  String get careBurnoutOverload => 'Sobrecarga de cuidado detectada';

  @override
  String get careBurnoutStretched => '¿Te sientes agotado?';

  @override
  String get careLoadTitle => 'Carga de cuidado';

  @override
  String get careLoadThisWeek => 'Esta semana';

  @override
  String get careCoachTitle => 'Coach de cuidado';

  @override
  String get careConfidenceTitle => 'Confianza en el cuidado';

  @override
  String get careConsistencyTitle => 'Consistencia del cuidado';

  @override
  String get careCostsTitle => 'Costos de cuidado';

  @override
  String get delegationPlanTitle => 'Plan de delegación';

  @override
  String get carePatternsTitle => 'Patrones de cuidado';

  @override
  String get carePersonaTitle => 'Tu personalidad de cuidado';

  @override
  String get carePersonaStrengths => 'Fortalezas';

  @override
  String get carePersonaGrowthAreas => 'Áreas de crecimiento';

  @override
  String get nextWateringTitle => 'Próximo riego';

  @override
  String get careRoutinesTitle => 'Tus rutinas de cuidado';

  @override
  String get plantAnniversariesTitle => 'Aniversarios de plantas';

  @override
  String get communityBenchmarkTitle => 'Referencia comunitaria';

  @override
  String get emotionalBondsTitle => 'Vínculos emocionales';

  @override
  String get suggestedGoalsTitle => 'Objetivos sugeridos';

  @override
  String get gardenHarmonyTitle => 'Armonía del jardín';

  @override
  String get gardenMomentumTitle => 'Impulso del jardín';

  @override
  String get gardenMoodTitle => 'Ambiente del jardín';

  @override
  String get gardenRhythmTitle => 'Ritmo del jardín';

  @override
  String get gardenCardTitle => 'Tarjeta del jardín';

  @override
  String get gardenStatsTitle => 'Estadísticas del jardín';

  @override
  String get growthJournalTitle => 'Diario de crecimiento';

  @override
  String get careHabitsTitle => 'Hábitos de cuidado';

  @override
  String get healthForecastTitle => 'Pronóstico de salud';

  @override
  String get healthTimelineTitle => 'Línea de tiempo de salud';

  @override
  String get plantQuizTitle => 'Quiz de plantas';

  @override
  String get growthStageTitle => 'Etapa de crecimiento';

  @override
  String get memoryLaneTitle => 'Paseo de recuerdos';

  @override
  String get microSeasonsTitle => 'Micro estaciones';

  @override
  String get milestonesTitle => 'Hitos';

  @override
  String get gentleNudgesTitle => 'Recordatorios suaves';

  @override
  String get timelapseReadyTitle => 'Timelapse listo';

  @override
  String get lifeStoryTitle => 'Historia de vida';

  @override
  String get plantLineageTitle => 'Linaje de la planta';

  @override
  String get rescuePlanTitle => 'Plan de rescate';

  @override
  String get plantStoryTitle => 'Historia de la planta';

  @override
  String get vitalSignsTitle => 'Signos vitales';

  @override
  String get predictedNeedsTitle => 'Necesidades previstas';

  @override
  String get propagationTitle => 'Propagación';

  @override
  String get roomProfilesTitle => 'Perfiles de habitación';

  @override
  String get seasonalTipsTitle => 'Consejos estacionales';

  @override
  String get skillLevelTitle => 'Nivel de habilidad';

  @override
  String get plantSocialGraphTitle => 'Grafo social de plantas';

  @override
  String get streakBoardTitle => 'Tabla de rachas';

  @override
  String get stressAlertsTitle => 'Alertas de estrés';

  @override
  String get survivalOutlookTitle => 'Perspectiva de supervivencia';

  @override
  String get gardenTimelineTitle => 'Línea de tiempo del jardín';

  @override
  String get waterEfficiencyTitle => 'Eficiencia de riego';

  @override
  String get wateringScheduleTitle => 'Calendario de riego';

  @override
  String get scheduleOptimizerTitle => 'Optimizador de horario';

  @override
  String get weeklyReportTitle => 'Esta semana';

  @override
  String get plantWhispererTitle => 'Susurrador de plantas';

  @override
  String get smartGreetingMorning => '¡Buenos días! Tus plantas te esperan.';

  @override
  String get smartGreetingAfternoon =>
      '¡Buenas tardes! Hora de revisar el jardín.';

  @override
  String get smartGreetingEvening =>
      '¡Buenas noches! Relájate con tus plantas.';

  @override
  String smartGreetingStreak(String days) {
    return '¡Racha de $days días! Sigue así.';
  }

  @override
  String get smartGreetingRainy =>
      'Día lluvioso — tus plantas de exterior están felices.';

  @override
  String smartGreetingNewPlant(String plant) {
    return '¿Cómo se está adaptando $plant?';
  }

  @override
  String get smartGreetingProductive =>
      '¡Día productivo! Tu jardín te lo agradece.';

  @override
  String get smartGreetingEarlyBird =>
      '¡Madrugador! Las plantas aman el cuidado matutino.';

  @override
  String smartGreetingLateNight(String count) {
    return 'Revisión nocturna de tus $count plantas.';
  }

  @override
  String smartGreetingBigGarden(String count) {
    return '¡$count plantas! Impresionante.';
  }

  @override
  String get smartGreetingDefault => 'Bienvenido de vuelta a tu jardín.';

  @override
  String nextActionWaterOverdue(String plant) {
    return 'Regar $plant';
  }

  @override
  String get nextActionWaterOverdueSub => 'Atrasado — necesita atención ahora';

  @override
  String nextActionWaterToday(String plant) {
    return 'Regar $plant';
  }

  @override
  String get nextActionWaterTodaySub => 'Programado para hoy';

  @override
  String get nextActionTakePhoto => 'Hora de la foto';

  @override
  String nextActionTakePhotoSub(String plant) {
    return 'Captura el progreso de $plant';
  }

  @override
  String nextActionCheckNewPlant(String plant) {
    return 'Revisa $plant';
  }

  @override
  String get nextActionCheckNewPlantSub => 'Planta nueva — conociéndose';

  @override
  String nextActionFertilize(String plant) {
    return 'Fertilizar $plant';
  }

  @override
  String get nextActionFertilizeSub => 'Próximamente en los siguientes días';

  @override
  String get nextActionCelebrate => '¡Celebra tu racha!';

  @override
  String get nextActionCelebrateSub => 'Lo estás haciendo increíble';

  @override
  String get nextActionExplore => 'Explorar nuevas plantas';

  @override
  String get nextActionExploreSub => 'Comienza tu viaje botánico';

  @override
  String get nextActionRest => '¡Todo al día!';

  @override
  String get nextActionRestSub => 'Tu jardín está feliz — disfruta el momento';

  @override
  String careRhythmStreakBadge(int count) {
    return '${count}x racha';
  }

  @override
  String get careRhythmMorningPerson => 'Madrugador';

  @override
  String get careRhythmMorningPersonDesc =>
      'Tiendes a cuidar tus plantas por la mañana.';

  @override
  String get careRhythmEveningCarer => 'Cuidador nocturno';

  @override
  String get careRhythmEveningCarerDesc =>
      'Tus plantas reciben atención al atardecer.';

  @override
  String get careRhythmWeekendWarrior => 'Guerrero de fin de semana';

  @override
  String get careRhythmWeekendWarriorDesc =>
      'Los fines de semana son tu momento para las plantas.';

  @override
  String get careRhythmDailyDevoter => 'Devoto diario';

  @override
  String get careRhythmDailyDevoterDesc =>
      'Revisas tus plantas casi todos los días.';

  @override
  String get careRhythmBatchCarer => 'Cuidador por lotes';

  @override
  String get careRhythmBatchCarerDesc =>
      'Cuidas varias plantas en sesiones concentradas.';

  @override
  String careRhythmConfidence(int percent) {
    return '$percent% coincidencia';
  }

  @override
  String get quickCheckInThanks => '¡Gracias por revisar!';

  @override
  String carePersonaMatch(int percent) {
    return '$percent% coincidencia';
  }

  @override
  String get carePersonaDevotee => 'Devoto';

  @override
  String get carePersonaExplorer => 'Explorador';

  @override
  String get carePersonaPerfectionist => 'Perfeccionista';

  @override
  String get carePersonaNurturer => 'Cuidador';

  @override
  String get carePersonaVeteran => 'Veterano';

  @override
  String get carePersonaEarlyBird => 'Madrugador';

  @override
  String plantPersonalityThe(String trait) {
    return 'El $trait';
  }

  @override
  String get plantPersonalityDedicated => 'Rutina de cuidado dedicada';

  @override
  String get plantPersonalityBalanced => 'Enfoque de cuidado equilibrado';

  @override
  String get plantPersonalityCasual => 'Estilo de cuidado casual';

  @override
  String get plantPersonalityMinimalist => 'Cuidado minimalista';

  @override
  String get careRoutineNight => 'Noche';

  @override
  String get careRoutineMorning => 'Mañana';

  @override
  String get careRoutineAfternoon => 'Tarde';

  @override
  String get careRoutineEvening => 'Atardecer';

  @override
  String careRoutinePlants(int count) {
    return '$count plantas';
  }

  @override
  String careRoutineMinPerWeek(int minutes) {
    return '$minutes min/semana';
  }

  @override
  String get confidenceMaster => 'Maestro de plantas';

  @override
  String get confidenceConfident => 'Cuidador seguro';

  @override
  String get confidenceLearning => 'Aprendiz en crecimiento';

  @override
  String get confidenceNovice => 'Novato en plantas';

  @override
  String get confidenceNextKeepGoing => 'Mantén la racha';

  @override
  String get confidenceNextMaster => 'Alcanza nivel Maestro';

  @override
  String get confidenceNextConfident => 'Alcanza nivel Seguro';

  @override
  String get confidenceNextBuild => 'Construye tu rutina';

  @override
  String confidenceNext(String milestone) {
    return 'Siguiente: $milestone';
  }

  @override
  String get confidenceDimConsistency => 'Consistencia';

  @override
  String get confidenceDimDiversity => 'Diversidad';

  @override
  String get confidenceDimHealth => 'Salud';

  @override
  String get confidenceDimExperience => 'Experiencia';

  @override
  String get confidenceDimVariety => 'Variedad';

  @override
  String get bondSoulmate => 'Alma gemela';

  @override
  String get bondBestFriend => 'Mejor amigo';

  @override
  String get bondCompanion => 'Compañero';

  @override
  String get bondNewFriend => 'Nuevo amigo';

  @override
  String get bondAcquaintance => 'Conocido';

  @override
  String bondSharedMoments(int count) {
    return '$count momentos compartidos';
  }

  @override
  String get calendarThisWeek => 'Esta semana';

  @override
  String calendarTasks(int count) {
    return '$count tareas';
  }

  @override
  String get calendarToday => 'hoy';

  @override
  String get calendarTomorrow => 'mañana';

  @override
  String calendarDaysShort(int days) {
    return '${days}d';
  }

  @override
  String get patternBatchCarer => 'Cuidador por lotes';

  @override
  String get patternMorningRitual => 'Ritual matutino';

  @override
  String get patternEveningRitual => 'Ritual nocturno';

  @override
  String get patternWeekendWarrior => 'Guerrero de fin de semana';

  @override
  String get patternSeasonalDip => 'Bajón estacional';

  @override
  String get patternSeasonalSurge => 'Auge estacional';

  @override
  String get patternFavoriteFirst => 'Favorito primero';

  @override
  String get patternNeedsLove => 'Necesita amor';

  @override
  String get patternDiverseRoutine => 'Rutina diversa';

  @override
  String get patternFocusedCarer => 'Cuidador enfocado';

  @override
  String get patternTitle => 'Tus patrones de cuidado';
}
