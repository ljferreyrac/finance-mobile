// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Solvi';

  @override
  String get loginTitle => 'Iniciar sesión';

  @override
  String get loginSubtitle => 'Controla tus gastos con inteligencia';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get emailHint => 'tu@correo.com';

  @override
  String get emailRequired => 'Ingresa tu correo electrónico';

  @override
  String get emailInvalid => 'Ingresa un correo válido';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get passwordRequired => 'Ingresa tu contraseña';

  @override
  String get passwordRequiredRegister => 'Ingresa una contraseña';

  @override
  String get passwordTooShort =>
      'La contraseña debe tener al menos 10 caracteres';

  @override
  String get passwordHelperText => 'Mínimo 10 caracteres';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get noAccount => '¿No tienes cuenta?';

  @override
  String get registerLink => 'Regístrate';

  @override
  String get registerTitle => 'Crear cuenta';

  @override
  String get fullNameLabel => 'Nombre completo';

  @override
  String get fullNameHint => 'Maria Garcia';

  @override
  String get fullNameRequired => 'Ingresa tu nombre completo';

  @override
  String get fullNameTooShort => 'El nombre debe tener al menos 2 caracteres';

  @override
  String get confirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get confirmPasswordRequired => 'Confirma tu contraseña';

  @override
  String get passwordsNoMatch => 'Las contraseñas no coinciden';

  @override
  String get registerButton => 'Crear cuenta';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta?';

  @override
  String get loginLink => 'Iniciar sesión';

  @override
  String get incorrectCredentials => 'Correo o contraseña incorrectos';

  @override
  String get mainCurrencyLabel => 'Moneda principal';

  @override
  String get solesCurrency => 'Soles (S/)';

  @override
  String get dollarsCurrency => 'Dólares (\$)';

  @override
  String get backTooltip => 'Volver';

  @override
  String get navTransactions => 'Transacciones';

  @override
  String get navAccounts => 'Cuentas';

  @override
  String get navReports => 'Reportes';

  @override
  String get navMore => 'Más';

  @override
  String get accountsTitle => 'Mis Cuentas';

  @override
  String get newAccount => 'Nueva cuenta';

  @override
  String get editAccount => 'Editar cuenta';

  @override
  String get accountTypeLabel => 'Tipo de cuenta';

  @override
  String get accountTypeBankLabel => 'Cuenta bancaria';

  @override
  String get accountTypeCreditCardLabel => 'Tarjeta de crédito';

  @override
  String get accountTypeCashLabel => 'Efectivo';

  @override
  String get accountTypeWalletLabel => 'Billetera digital';

  @override
  String get accountNameLabel => 'Nombre';

  @override
  String get accountNameHint => 'Ej: BCP Ahorros';

  @override
  String get accountNameRequired => 'Ingresa un nombre';

  @override
  String get linkedBankAccount => 'Cuenta bancaria asociada';

  @override
  String get linkedBankAccountHelper =>
      'Los gastos con esta billetera descontarán de esta cuenta';

  @override
  String get noLinkedAccount => 'Sin cuenta asociada';

  @override
  String get currencyLabel => 'Moneda';

  @override
  String get initialBalanceLabel => 'Saldo inicial';

  @override
  String get colorLabel => 'Color';

  @override
  String get changeColor => 'Cambiar color';

  @override
  String get chooseColor => 'Elegir color';

  @override
  String get chooseIcon => 'Elegir icono';

  @override
  String get creditLimitLabel => 'Límite de crédito';

  @override
  String get closingDayLabel => 'Día de cierre';

  @override
  String get dueDayLabel => 'Día de vencimiento';

  @override
  String get dayHint => '1-31';

  @override
  String get dayInvalid => 'Día inválido';

  @override
  String get isDefaultAccount => 'Cuenta predeterminada';

  @override
  String get isDefaultAccountSubtitle =>
      'Se usará en nuevas transacciones por defecto';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String deleteAccountConfirm(String name) {
    return 'Eliminar \"$name\"? Esta acción no se puede deshacer.';
  }

  @override
  String accountInUse(String name, int count) {
    return '\"$name\" tiene $count transacción(es). Reasigna o elimina esas transacciones antes de eliminar la cuenta.';
  }

  @override
  String get netWorthTitle => 'Patrimonio neto';

  @override
  String get emptyAccounts => 'No tienes cuentas. Agrega una para empezar.';

  @override
  String get defaultLabel => 'Por defecto';

  @override
  String get balanceInAccount => 'Balance en cuenta';

  @override
  String get transactionsTitle => 'Transacciones';

  @override
  String get newTransaction => 'Nueva transacción';

  @override
  String get editTransaction => 'Editar transacción';

  @override
  String get saveTransaction => 'Guardar transacción';

  @override
  String get deleteTransaction => 'Eliminar transacción';

  @override
  String get deleteTransactionConfirm =>
      '¿Esta acción no se puede deshacer. Continuar?';

  @override
  String get transactionTypeExpense => 'Gasto';

  @override
  String get transactionTypeIncome => 'Ingreso';

  @override
  String get transactionTypeTransfer => 'Transferencia';

  @override
  String get transactionTypeTransferShort => 'Transfer.';

  @override
  String get amountLabel => 'Monto';

  @override
  String get amountRequired => 'Ingresa un monto';

  @override
  String get amountInvalid => 'Monto inválido';

  @override
  String get dateLabel => 'Fecha';

  @override
  String get merchantLabelExpense => 'Comercio (opcional)';

  @override
  String get merchantLabelIncome => 'Fuente (opcional)';

  @override
  String get descriptionLabel => 'Descripción (opcional)';

  @override
  String get accountLabel => 'Cuenta';

  @override
  String get selectAccount => 'Seleccionar cuenta';

  @override
  String get fromAccountLabel => 'Cuenta de origen';

  @override
  String get toAccountLabel => 'Cuenta de destino';

  @override
  String get selectFromAccount => 'Seleccionar cuenta origen';

  @override
  String get selectToAccount => 'Seleccionar cuenta destino';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get categoryRequired => 'Categoría (requerida)';

  @override
  String get categoryOptional => 'Categoría (opcional)';

  @override
  String get selectCategory => 'Seleccionar categoría';

  @override
  String get tagsLabel => 'Etiquetas (opcional)';

  @override
  String get selectTags => 'Seleccionar etiquetas';

  @override
  String get selectAccountsFirst =>
      'Selecciona las cuentas de origen y destino';

  @override
  String get selectCategoryFirst => 'Selecciona una categoría';

  @override
  String get selectAccountFirst => 'Selecciona una cuenta';

  @override
  String get sameAccountError =>
      'Las cuentas de origen y destino deben ser distintas';

  @override
  String receivedAmountLabel(String currency) {
    return 'Monto recibido ($currency)';
  }

  @override
  String get transactionCreated => 'Transacción creada';

  @override
  String get transactionUpdated => 'Transacción actualizada';

  @override
  String get transactionDeleted => 'Transacción eliminada';

  @override
  String get emptyTransactions =>
      'No hay transacciones. Agrega una para empezar.';

  @override
  String get emptyExpenses => 'No hay gastos registrados en este período.';

  @override
  String get emptyIncome => 'No hay ingresos registrados en este período.';

  @override
  String get emptyTransfers =>
      'No hay transferencias registradas en este período.';

  @override
  String get filterAll => 'Todos';

  @override
  String get filterExpenses => 'Gastos';

  @override
  String get filterIncome => 'Ingresos';

  @override
  String get filterTransfers => 'Transferencias';

  @override
  String get noAccountsAvailable => 'No hay cuentas disponibles.';

  @override
  String get noCategoriesAvailable => 'No hay categorías. Crea una primero.';

  @override
  String get tagsTitle => 'Etiquetas';

  @override
  String get newTag => 'Nueva etiqueta';

  @override
  String get editTag => 'Editar etiqueta';

  @override
  String get createTag => 'Crear etiqueta';

  @override
  String get deleteTag => 'Eliminar etiqueta';

  @override
  String get tagNameLabel => 'Nombre';

  @override
  String get tagNameHint => 'Ej. Trabajo';

  @override
  String get tagNameRequired => 'El nombre es obligatorio';

  @override
  String get tagColorLabel => 'Color (opcional)';

  @override
  String get noColor => 'Sin color';

  @override
  String get emptyTags =>
      'Aun no tienes etiquetas. Crea una para organizarlas.';

  @override
  String get deleteTagConfirm => 'Eliminar etiqueta';

  @override
  String deleteTagMessage(String name) {
    return 'Eliminar \"$name\"? Esta acción no se puede deshacer.';
  }

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get categoriesTitle => 'Mis Categorías';

  @override
  String get newCategory => 'Nueva categoría';

  @override
  String get editCategory => 'Editar categoría';

  @override
  String get createCategory => 'Crear categoría';

  @override
  String get deleteCategory => 'Eliminar categoría';

  @override
  String get categoryNameLabel => 'Nombre';

  @override
  String get categoryNameHint => 'Ej. Comida';

  @override
  String get categoryColorLabel => 'Color';

  @override
  String get categoryIconLabel => 'Icono';

  @override
  String get noIcon => 'Sin icono';

  @override
  String get categoryNameRequired => 'El nombre es obligatorio';

  @override
  String get defaultCategory => 'Usar como categoría predeterminada';

  @override
  String get defaultCategorySubtitle =>
      'Se pre-seleccionará al registrar un nuevo gasto';

  @override
  String get deleteCategoryTitle => 'Eliminar categoría';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Eliminar \"$name\"? Esta acción no se puede deshacer.';
  }

  @override
  String get reassignExpenses => 'Reasignar gastos';

  @override
  String reassignMessage(String name, int count) {
    return '\"$name\" tiene $count gasto(s). Selecciona una categoría de reemplazo:';
  }

  @override
  String get noOtherCategories =>
      'No hay otras categorías disponibles. Crea una primero.';

  @override
  String get deleteAndReassign => 'Eliminar y reasignar';

  @override
  String get categoryCreated => 'Categoría creada';

  @override
  String get categoryUpdated => 'Categoría actualizada';

  @override
  String get categoryDeleted => 'Categoría eliminada';

  @override
  String get categorySetDefault => 'Categoría establecida como predeterminada';

  @override
  String get setAsDefault => 'Establecer como defecto';

  @override
  String get emptyCategories => 'No tienes categorías. Crea una para empezar.';

  @override
  String expenseCount(int count) {
    return '$count gasto(s)';
  }

  @override
  String get reportsTitle => 'Reportes';

  @override
  String get monthly => 'Mensual';

  @override
  String get yearly => 'Anual';

  @override
  String get previousPeriod => 'Período anterior';

  @override
  String get nextPeriod => 'Período siguiente';

  @override
  String get totalPeriod => 'Total del período';

  @override
  String get noDataPeriod => 'Sin datos para este período';

  @override
  String get byCategory => 'Por categoría';

  @override
  String get byWeek => 'Por semana';

  @override
  String get byMonth => 'Por mes';

  @override
  String get topCategory => 'Top categoría';

  @override
  String get topMerchants => 'Principales comercios';

  @override
  String get transactions => 'transacciones';

  @override
  String transactionCountLabel(int count) {
    return '$count transacciones';
  }

  @override
  String get dailyAverage => 'Promedio diario';

  @override
  String get monthlyAverage => 'Promedio mensual';

  @override
  String incomeLabel(int count) {
    return 'Ingresos ($count)';
  }

  @override
  String get netBalance => 'Balance neto';

  @override
  String vsLastMonth(String amount) {
    return 'vs $amount el mes anterior';
  }

  @override
  String get yearHighlights => 'Destacados del año';

  @override
  String get peakMonth => 'Mes pico';

  @override
  String get lowestMonth => 'Mes mínimo';

  @override
  String get filterTooltip => 'Filtrar';

  @override
  String get filterTitle => 'Filtros';

  @override
  String get filterAccount => 'Cuenta';

  @override
  String get filterCategory => 'Categoría';

  @override
  String get filterTag => 'Etiqueta';

  @override
  String get clearFilters => 'Limpiar';

  @override
  String get applyFilters => 'Aplicar';

  @override
  String get closeTooltip => 'Cerrar';

  @override
  String get noAccounts => 'Sin cuentas';

  @override
  String get noCategories => 'Sin categorías';

  @override
  String get noTags => 'Sin etiquetas';

  @override
  String get moreTitle => 'Más';

  @override
  String get organizationSection => 'Organización';

  @override
  String get categoriesSubtitle => 'Gestiona tus categorías de gastos';

  @override
  String get tagsSubtitle => 'Organiza tus transacciones con etiquetas';

  @override
  String get languageSection => 'Idioma';

  @override
  String get spanishLanguage => 'Español';

  @override
  String get englishLanguage => 'English';

  @override
  String get accountSection => 'Cuenta';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logoutTitle => '¿Cerrar sesión?';

  @override
  String get logoutMessage =>
      'Se cerrará tu sesión en este dispositivo. Podrás volver a iniciar sesión cuando quieras.';

  @override
  String get logoutConfirm => 'Cerrar sesión';

  @override
  String get retry => 'Reintentar';

  @override
  String get error => 'Error';

  @override
  String get loading => 'Cargando...';

  @override
  String get noData => 'Sin datos';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get typeLabel => 'Tipo';

  @override
  String get dateDetailLabel => 'Fecha';

  @override
  String get currencyDetailLabel => 'Moneda';

  @override
  String get merchantDetailLabel => 'Comercio';

  @override
  String get descriptionDetailLabel => 'Descripción';

  @override
  String get accountDetailLabel => 'Cuenta';

  @override
  String get nameDetailLabel => 'Nombre';

  @override
  String get transferDetailLabel => 'Transferencia';

  @override
  String get fromLabel => 'Desde';

  @override
  String get toLabel => 'Hacia';

  @override
  String get registeredLabel => 'Registrado';

  @override
  String get editTooltip => 'Editar';

  @override
  String get deleteTooltip => 'Eliminar';

  @override
  String get filtersTooltip => 'Filtros';

  @override
  String get searchOrCreateTag => 'Buscar o crear etiqueta';

  @override
  String get newTagColor => 'Color para la nueva etiqueta';

  @override
  String createTagInline(String name) {
    return 'Crear etiqueta \"$name\"';
  }

  @override
  String get done => 'Listo';

  @override
  String get amountLocalLabel => 'Equivalente en S/';

  @override
  String get amountLocalLabelUsd => 'Equivalente en \$';

  @override
  String exchangeRateHelper(String rate) {
    return 'Tipo de cambio: S/ $rate';
  }

  @override
  String get onboardingStep1StepLabel => 'Paso 1 de 2 - Cuentas';

  @override
  String get onboardingStep2StepLabel => 'Paso 2 de 2 - Categorias';

  @override
  String get onboardingStep1Title => 'Agrega tus cuentas';

  @override
  String get onboardingStep1Subtitle =>
      'Agrega al menos una cuenta para empezar a registrar tus finanzas.';

  @override
  String get onboardingAccountTypeQuestion => '¿Que tipo de cuenta es?';

  @override
  String get onboardingAccountNameQuestion => '¿Como quieres llamarla?';

  @override
  String get onboardingAccountNameHint => 'Ej. Cuenta sueldo BCP';

  @override
  String get onboardingAccountNameRequired => 'Ingresa un nombre';

  @override
  String get onboardingInitialBalanceInvalid => 'Ingresa un monto valido';

  @override
  String get onboardingSavingLabel => 'Guardando...';

  @override
  String get onboardingAddAccountButton => 'Agregar cuenta';

  @override
  String get onboardingAccountsAddedLabel => 'Cuentas agregadas';

  @override
  String get onboardingContinueButton => 'Continuar';

  @override
  String get onboardingGenericError =>
      'Algo salio mal. Por favor intenta de nuevo.';

  @override
  String get onboardingStep2Title => 'Elige tus categorias';

  @override
  String get onboardingStep2Subtitle =>
      'Selecciona las categorias que mejor representan tus gastos e ingresos. Puedes agregar mas despues.';

  @override
  String get onboardingExpensesGroup => 'Gastos';

  @override
  String get onboardingIncomeGroup => 'Ingresos';

  @override
  String get onboardingAddCustomCategory => 'Agregar categoria personalizada';

  @override
  String get onboardingFinishButton => 'Finalizar';

  @override
  String get onboardingCategoriesError =>
      'No se pudieron guardar las categorias. Intenta de nuevo.';

  @override
  String get catFood => 'Comida';

  @override
  String get catTransport => 'Transporte';

  @override
  String get catHousing => 'Vivienda';

  @override
  String get catHealth => 'Salud';

  @override
  String get catEntertainment => 'Entretenimiento';

  @override
  String get catShopping => 'Compras';

  @override
  String get catEducation => 'Educacion';

  @override
  String get catPersonalCare => 'Cuidado Personal';

  @override
  String get catUtilities => 'Servicios';

  @override
  String get catTravel => 'Viajes';

  @override
  String get catSalary => 'Sueldo';

  @override
  String get catFreelance => 'Freelance';

  @override
  String get catInvestments => 'Inversiones';

  @override
  String get catOtherIncome => 'Otros Ingresos';

  @override
  String get onboardingNewCategoryTitle => 'Nueva categoria';

  @override
  String get onboardingCategoryNameHint => 'Nombre de la categoria';

  @override
  String get onboardingIconSectionLabel => 'Icono';

  @override
  String get onboardingAddButton => 'Agregar';

  @override
  String get emptyTransactionsHint =>
      'Usa el boton + para registrar tu primer movimiento, o prueba el microfono para hacerlo por voz.';

  @override
  String get emptyExpensesHint =>
      'Registra un gasto con el boton + o di lo que gastaste por voz.';

  @override
  String get emptyIncomeHint =>
      'Agrega un ingreso cuando recibas dinero: sueldo, freelance, lo que sea.';

  @override
  String get emptyTransfersHint =>
      'Las transferencias entre tus cuentas apareceran aqui.';

  @override
  String get registerLanguageLabel => 'Idioma';

  @override
  String get netWorthIncludeDebtTooltip =>
      'Mostrando patrimonio neto (incluye deudas)';

  @override
  String get netWorthAssetsOnlyTooltip => 'Mostrando solo activos';

  @override
  String get netWorthAssetsOnlyTitle => 'Activos';

  @override
  String get accountActiveLabel => 'Cuenta activa';

  @override
  String get accountActiveSubtitle =>
      'Las cuentas inactivas no aparecen en el patrimonio neto';

  @override
  String get accountCreated => 'Cuenta creada';

  @override
  String get accountUpdated => 'Cuenta actualizada';

  @override
  String get accountDeleted => 'Cuenta eliminada';

  @override
  String get accountSetDefault => 'Cuenta establecida como predeterminada';

  @override
  String get authInvalidCredentials => 'Correo o contraseña incorrectos';

  @override
  String get noInternetConnection => 'Sin conexion a internet';

  @override
  String get emailAlreadyRegistered => 'Este correo ya esta registrado';

  @override
  String get micPermissionRequired =>
      'Se necesita permiso de microfono para grabar audio.';

  @override
  String get recordingFileNotFound =>
      'No se encontro el archivo de audio grabado.';

  @override
  String get someTransactionsFailedToSave =>
      'Algunas transacciones no se pudieron guardar.';

  @override
  String get voiceRecordTitle => 'Registrar por voz';

  @override
  String get voiceRecordingStatus => 'Grabando... toca para detener';

  @override
  String get voiceProcessingStatus => 'Procesando...';

  @override
  String get voiceIdleStatus => 'Toca el microfono y describe tus gastos';

  @override
  String get voiceRecordingLabel => 'Grabando';

  @override
  String get voiceTranscribingLabel => 'Transcribiendo y analizando...';

  @override
  String get voiceIdleExample =>
      'Describe uno o varios gastos,\npor ejemplo: \"Gaste 45 soles en el mercado\ny 12 en el bus\"';

  @override
  String get voiceNeedsAccountMessage =>
      'Necesitas al menos una cuenta para usar el registro por voz.';

  @override
  String get voiceNeedsCategoryMessage =>
      'Necesitas al menos una categoria para usar el registro por voz.';

  @override
  String voiceTransactionsSavedCount(int count) {
    return '$count transaccion(es) guardada(s)';
  }

  @override
  String get voiceReviewTitle => 'Revisar transacciones';

  @override
  String get voiceNoTransactionsFound => 'No se encontraron transacciones';

  @override
  String get voiceRecordAgain => 'Volver a grabar';

  @override
  String get voiceCompleteRequiredFields => 'Completa los campos requeridos';

  @override
  String voiceConfirmCount(int count) {
    return 'Confirmar $count transaccion(es)';
  }

  @override
  String get voiceLowConfidenceTooltip => 'Confianza baja: revisa este campo';

  @override
  String get voiceCategoryRequired => 'Categoria requerida';

  @override
  String get voiceAccountRequired => 'Cuenta requerida';

  @override
  String get voiceNoCategorySelected => 'Sin categoria';

  @override
  String get voiceNoAccountSelected => 'Sin cuenta';
}
