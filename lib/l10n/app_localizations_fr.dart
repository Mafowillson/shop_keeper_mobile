// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'ShopKeeper';

  @override
  String get tagline => 'Gérez votre boutique, développez votre activité';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get search => 'Rechercher';

  @override
  String get retry => 'Réessayer';

  @override
  String get back => 'Retour';

  @override
  String get done => 'Terminé';

  @override
  String get confirm => 'Confirmer';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get success => 'Succès';

  @override
  String get error => 'Erreur';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get noDataFound => 'Aucune donnée trouvée';

  @override
  String get somethingWentWrong => 'Une erreur est survenue';

  @override
  String get required => 'Obligatoire';

  @override
  String get fieldRequired => 'Ce champ est obligatoire';

  @override
  String get enterValidEmail => 'Entrez une adresse e-mail valide';

  @override
  String get passwordMinLength =>
      'Le mot de passe doit comporter au moins 6 caractères';

  @override
  String get passwordRequired => 'Mot de passe obligatoire';

  @override
  String get passwordMinSixChars =>
      'Le mot de passe doit comporter au moins 6 caractères';

  @override
  String get pleaseConfirmPassword => 'Confirmez votre mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get fcfa => 'FCFA';

  @override
  String get savingEllipsis => 'Enregistrement…';

  @override
  String get loadingEllipsis => 'Chargement…';

  @override
  String get processingEllipsis => 'Traitement…';

  @override
  String get recordingEllipsis => 'Enregistrement…';

  @override
  String get remove => 'Supprimer';

  @override
  String get add => 'Ajouter';

  @override
  String get clear => 'Effacer';

  @override
  String get notSet => 'Non défini';

  @override
  String get enterWholeNumber => 'Entrez un nombre entier';

  @override
  String get mustBePositive => 'Doit être > 0';

  @override
  String get minOne => 'Min 1';

  @override
  String get nameMinTwoChars => 'Le nom doit comporter au moins 2 caractères';

  @override
  String get enterValidEmailAddress => 'Entrez une adresse e-mail valide';

  @override
  String get enterValidPhone =>
      'Entrez un numéro de téléphone valide (min 9 chiffres)';

  @override
  String get hintEmail => 'votre@email.com';

  @override
  String get hintExEmail => 'ex. votre@email.com';

  @override
  String get hintExFullName => 'ex. Jean-Paul Mbassi';

  @override
  String get hintExPhone => 'ex. 677 000 000';

  @override
  String get hintExPhoneIntl => 'ex. 237612345678';

  @override
  String get hintExShopName => 'ex. Boutique Wilson';

  @override
  String get hintExShopLocation => 'ex. Bamenda, Cameroun';

  @override
  String get hintExProductName => 'ex. Sucre en morceaux';

  @override
  String get hintExUnitName => 'ex. carton';

  @override
  String get hintExThreshold => 'ex. 5';

  @override
  String get hintExQtyInBase => 'ex. 25';

  @override
  String get hintExPrice => 'ex. 21 000';

  @override
  String get welcomeBack => 'Bienvenue';

  @override
  String get signInToContinue => 'Connectez-vous pour continuer';

  @override
  String get signIn => 'Se connecter';

  @override
  String get newHere => 'Nouveau ici ?';

  @override
  String get createAnAccount => 'Créer un compte';

  @override
  String get email => 'E-mail';

  @override
  String get emailAddress => 'Adresse e-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get ownerRole => 'Propriétaire';

  @override
  String get staffRole => 'Employé';

  @override
  String get registerOwnerAccount => 'Créer un compte propriétaire';

  @override
  String get createSecureAccount =>
      'Créez un compte sécurisé pour gérer votre commerce';

  @override
  String get fullName => 'Nom complet';

  @override
  String get minimumSixChars => 'Minimum 6 caractères';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get growRetailBusiness => 'Développez votre commerce efficacement';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get forgotPasswordDescription =>
      'Entrez votre adresse e-mail et nous vous enverrons les instructions pour réinitialiser votre mot de passe.';

  @override
  String get sendRecoveryEmail => 'Envoyer l\'e-mail de récupération';

  @override
  String get backToSignIn => 'Retour à la connexion';

  @override
  String get checkYourInbox => 'Vérifiez votre boîte mail';

  @override
  String get passwordRecoveryInstructions =>
      'Nous avons envoyé les instructions de récupération à :';

  @override
  String get enterResetCode => 'Entrer le code de réinitialisation';

  @override
  String get verifyYourEmail => 'Vérifiez votre e-mail';

  @override
  String get enterCodeSentTo => 'Entrez le code à 6 chiffres envoyé à';

  @override
  String get verifyEmailButton => 'Vérifier l\'e-mail';

  @override
  String get didntReceiveCode => 'Vous n\'avez pas reçu le code ?';

  @override
  String get resend => 'Renvoyer';

  @override
  String resendInSeconds(int seconds) {
    return 'Renvoyer dans ${seconds}s';
  }

  @override
  String get useDifferentAccount => 'Utiliser un autre compte';

  @override
  String get resetPasswordTitle => 'Réinitialiser le mot de passe';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get didntReceiveIt => 'Pas reçu ?';

  @override
  String get registerYourShop => 'Enregistrer votre boutique';

  @override
  String get shopName => 'Nom de la boutique';

  @override
  String get shopLocation => 'Localisation / Adresse (facultatif)';

  @override
  String get completeOnboarding => 'Terminer l\'inscription';

  @override
  String get welcomeToShopKeeper => 'Bienvenue sur ShopKeeper';

  @override
  String get setUpBusinessDetails =>
      'Configurons les détails de votre commerce';

  @override
  String get recoverPasswordSecurely =>
      'Récupérez votre mot de passe en toute sécurité';

  @override
  String get accountCreatedSuccessfully => 'Compte créé avec succès !';

  @override
  String get shopRegisteredSuccessfully => 'Boutique enregistrée avec succès !';

  @override
  String get passwordResetSuccess =>
      'Mot de passe réinitialisé ! Connectez-vous avec votre nouveau mot de passe.';

  @override
  String get invalidCodeTryAgain => 'Code invalide. Veuillez réessayer.';

  @override
  String get newCodeSent => 'Un nouveau code a été envoyé.';

  @override
  String get couldNotSendCode => 'Impossible d\'envoyer le code. Réessayez.';

  @override
  String get passwordResetFailed =>
      'Réinitialisation échouée. Veuillez réessayer.';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get notifications => 'Notifications';

  @override
  String get profile => 'Profil';

  @override
  String get home => 'Accueil';

  @override
  String get sales => 'Ventes';

  @override
  String get products => 'Produits';

  @override
  String get customers => 'Clients';

  @override
  String get settings => 'Paramètres';

  @override
  String get staff => 'Personnel';

  @override
  String helloName(String name) {
    return 'Bonjour, $name';
  }

  @override
  String get todaysRevenue => 'Chiffre d\'affaires du jour';

  @override
  String get transactions => 'Transactions';

  @override
  String get revenueLastSevenDays => 'Recettes — 7 derniers jours';

  @override
  String get weeklyTotal => 'Total semaine';

  @override
  String get quickActions => 'Actions rapides';

  @override
  String get recentActivity => 'Activité récente';

  @override
  String get noRecentActivity => 'Aucune activité récente';

  @override
  String timeAgoMinutes(int count) {
    return 'il y a $count min';
  }

  @override
  String timeAgoHours(int count) {
    return 'il y a $count h';
  }

  @override
  String timeAgoDays(int count) {
    return 'il y a $count j';
  }

  @override
  String get stockOk => 'Stock OK';

  @override
  String get noDebts => 'Pas de dettes';

  @override
  String get addProduct => 'Ajouter un produit';

  @override
  String get viewSales => 'Voir les ventes';

  @override
  String get debts => 'Dettes';

  @override
  String get aiInsights => 'Analyses IA';

  @override
  String get editProduct => 'Modifier le produit';

  @override
  String get searchProductsHint => 'Rechercher des produits…';

  @override
  String get productName => 'Nom du produit';

  @override
  String get productCreatedSuccessfully => 'Produit créé avec succès';

  @override
  String get productUpdated => 'Produit mis à jour';

  @override
  String get category => 'Catégorie';

  @override
  String get categoryBeverages => 'Boissons';

  @override
  String get categorySnacksSweets => 'Snacks & Sucreries';

  @override
  String get categoryGrainsStaples => 'Céréales & Féculents';

  @override
  String get categoryDairyEggs => 'Produits laitiers & Œufs';

  @override
  String get categoryCleaningHygiene => 'Nettoyage & Hygiène';

  @override
  String get categoryHousehold => 'Maison';

  @override
  String get categoryToiletries => 'Articles de toilette';

  @override
  String get categoryOther => 'Autre';

  @override
  String get productInfo => 'Info produit';

  @override
  String get nameAndCategory => 'Nom et catégorie';

  @override
  String get units => 'Unités';

  @override
  String get unitName => 'Nom de l\'unité';

  @override
  String get qtyInBase => 'Qté en base';

  @override
  String get priceFCFA => 'Prix (FCFA)';

  @override
  String get perUnit => '/ unité';

  @override
  String get addAnotherUnit => 'Ajouter une autre unité';

  @override
  String get openingStock => 'Stock initial';

  @override
  String get currentStock => 'Stock actuel';

  @override
  String get lowStockAlert => 'Alerte stock faible';

  @override
  String get removeProduct => 'Supprimer le produit ?';

  @override
  String get noProductsYet => 'Pas encore de produits';

  @override
  String get addFirstProduct =>
      'Ajoutez votre premier produit pour commencer à suivre votre stock.';

  @override
  String get noProductsMatchSearch =>
      'Aucun produit ne correspond à votre recherche';

  @override
  String get addProductTooltip => 'Ajouter un produit';

  @override
  String get available => 'disponible';

  @override
  String get baseUnitHint =>
      'C\'est l\'unité de base — le stock est suivi dans cette unité';

  @override
  String get howManyBaseUnits => 'Combien d\'unités de base dans cette unité';

  @override
  String get inStock => 'En stock';

  @override
  String get outOfStock => 'Rupture de stock';

  @override
  String lowStockLabel(int qty) {
    return 'Faible ($qty)';
  }

  @override
  String deactivateProductConfirm(String name) {
    return 'Ceci désactivera « $name » de votre inventaire.';
  }

  @override
  String get unitsFallback => 'unités';

  @override
  String get baseUnitBadge => 'BASE';

  @override
  String get openingStockSubtitle =>
      'Entrez ce que vous avez maintenant — laissez vide pour démarrer à zéro';

  @override
  String get currentStockSubtitle =>
      'Le stock est mis à jour automatiquement lors de l\'enregistrement des ventes';

  @override
  String get errorOneUnitMustBeBase =>
      'Une unité doit avoir une quantité en base = 1 (l\'unité de base).';

  @override
  String get errorOnlyOneBase =>
      'Une seule unité peut avoir une quantité en base = 1.';

  @override
  String get errorUnitNamesUnique => 'Les noms d\'unités doivent être uniques.';

  @override
  String unitNumber(int number) {
    return 'Unité $number';
  }

  @override
  String stockTotal(int count, String unit) {
    return 'Total : $count $unit';
  }

  @override
  String lowStockAlertSubtitle(String unit) {
    return 'Alerte quand le stock descend en dessous de ce seuil ($unit)';
  }

  @override
  String thresholdLabel(String unit) {
    return 'Seuil (en $unit)';
  }

  @override
  String get newSale => 'Nouvelle vente';

  @override
  String get salesHistory => 'Historique des ventes';

  @override
  String get saleDetail => 'Détail de la vente';

  @override
  String get items => 'Articles';

  @override
  String get payment => 'Paiement';

  @override
  String get paymentType => 'Type de paiement';

  @override
  String get cash => 'Espèces';

  @override
  String get credit => 'Crédit';

  @override
  String get paid => 'Payé';

  @override
  String get total => 'Total';

  @override
  String get change => 'Rendu';

  @override
  String get amountPaid => 'Montant payé';

  @override
  String get saleTotal => 'Total de la vente';

  @override
  String get selectCustomerHint => 'Sélectionner un client…';

  @override
  String get customerRequiredForCredit =>
      'Un client est requis pour les ventes à crédit.';

  @override
  String get fullAmountAsDebt =>
      'Le montant total sera enregistré comme dette.';

  @override
  String get partialPaymentNote =>
      'Le solde restant sera enregistré comme dette pour ce client.';

  @override
  String get checkout => 'Valider';

  @override
  String get proceedToPayment => 'Procéder au paiement';

  @override
  String get all => 'Tout';

  @override
  String get clearAll => 'Tout effacer';

  @override
  String get cart => 'Panier';

  @override
  String get cartIsEmpty => 'Panier vide';

  @override
  String get noSalesFound => 'Aucune vente trouvée';

  @override
  String saleRef(String ref) {
    return 'Vente #$ref';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
    );
    return '$_temp0';
  }

  @override
  String get saleRecorded => 'Vente enregistrée';

  @override
  String get paymentSuccessful => 'Paiement réussi !';

  @override
  String get receipt => 'Reçu';

  @override
  String get shareReceipt => 'Partager le reçu';

  @override
  String get pdfReceipt => 'Reçu PDF';

  @override
  String get owedCredit => 'Dû (crédit)';

  @override
  String get noSalesYet => 'Aucune vente enregistrée aujourd\'hui';

  @override
  String get transactionsWillAppear => 'Vos transactions apparaîtront ici';

  @override
  String get startRecordingSale => 'Toucher pour commencer une vente';

  @override
  String get todayTransactions => 'Transactions du jour';

  @override
  String get cashSale => 'Vente au comptant';

  @override
  String get creditSale => 'Vente à crédit';

  @override
  String get noProductsInCategory => 'Aucun produit dans cette catégorie';

  @override
  String get totalRevenue => 'Recettes totales';

  @override
  String get owed => 'Dû';

  @override
  String get pending => 'En attente';

  @override
  String get addCustomer => 'Ajouter un client';

  @override
  String get totalOutstandingDebt => 'Total des dettes impayées';

  @override
  String get recordPayment => 'Enregistrer un paiement';

  @override
  String get amount => 'Montant';

  @override
  String get transactionHistory => 'Historique des transactions';

  @override
  String get saveCustomer => 'Enregistrer le client';

  @override
  String get noCustomersFound => 'Aucun client trouvé';

  @override
  String get searchByNameOrPhone => 'Rechercher par nom ou téléphone…';

  @override
  String get debtLabel => 'Dette :';

  @override
  String get outstandingDebt => 'Dette impayée';

  @override
  String get debtRecords => 'Enregistrements de dettes';

  @override
  String get noTransactionsYet => 'Aucune transaction pour le moment';

  @override
  String get noteOptional => 'Note (facultatif)';

  @override
  String get phoneOptional => 'Téléphone (facultatif)';

  @override
  String get newCustomer => 'Nouveau client';

  @override
  String get saveAndSelect => 'Enregistrer et sélectionner';

  @override
  String get selectCustomer => 'Sélectionner un client';

  @override
  String get walkInCustomer => 'Client de passage';

  @override
  String get newButton => 'Nouveau';

  @override
  String get createNewCustomer => 'Créer un nouveau client';

  @override
  String get creditRecord => 'Crédit';

  @override
  String get paymentRecord => 'Paiement';

  @override
  String get balance => 'Solde :';

  @override
  String get withDebt => 'Avec dette';

  @override
  String get addStaffMember => 'Ajouter un membre du personnel';

  @override
  String get createStaffAccount => 'Créer un compte personnel';

  @override
  String get staffCreatedSuccessfully => 'Compte créé avec succès';

  @override
  String get deactivate => 'Désactiver';

  @override
  String get activate => 'Activer';

  @override
  String get manageStaff => 'Gérer le personnel';

  @override
  String get activateOrDeactivateTeam =>
      'Activer ou désactiver les membres de l\'équipe';

  @override
  String get noStaffYet => 'Pas encore de personnel';

  @override
  String get addStaffFromProfile => 'Ajoutez du personnel depuis votre profil.';

  @override
  String get couldNotLoadStaff => 'Impossible de charger le personnel';

  @override
  String get active => 'Actif';

  @override
  String get inactive => 'Inactif';

  @override
  String get accountDetails => 'Détails du compte';

  @override
  String get newStaffAccount => 'Nouveau compte personnel';

  @override
  String get fillInStaffDetails =>
      'Remplissez les informations ci-dessous pour créer les identifiants de connexion de votre employé.';

  @override
  String get phoneAsPassword =>
      'Le numéro de téléphone sert de mot de passe à cet employé. Partagez son e-mail et son numéro pour qu\'il puisse se connecter à ShopKeeper.';

  @override
  String get salesToday => 'Ventes du jour';

  @override
  String get revenue => 'Recettes';

  @override
  String get priceList => 'Liste des prix';

  @override
  String get viewAllProducts => 'Voir tous les produits et prix';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get availableLabel => 'Disponible';

  @override
  String get failedCreateStaff => 'Échec de la création du personnel';

  @override
  String get markAllRead => 'Tout marquer comme lu';

  @override
  String get noNotifications => 'Aucune notification';

  @override
  String get allCaughtUp => 'Tout est à jour';

  @override
  String get allCaughtUpPeriod => 'Vous êtes à jour.';

  @override
  String get tapToDismiss => 'Toucher pour ignorer';

  @override
  String unreadCount(int count) {
    return '$count non lus';
  }

  @override
  String get customizeExperience => 'Personnalisez votre expérience';

  @override
  String get languageSetting => 'Langue';

  @override
  String get appDisplayLanguage => 'Langue d\'affichage';

  @override
  String get displayLanguage => 'Langue d\'affichage';

  @override
  String get alertPreferences => 'Préférences d\'alertes';

  @override
  String get chooseAlerts => 'Choisissez les événements qui vous notifient';

  @override
  String get lowStockAlerts => 'Alertes stock faible';

  @override
  String get notifyWhenLowStock =>
      'Notifier quand un produit est presque épuisé';

  @override
  String get largeSaleAlerts => 'Alertes grosses ventes';

  @override
  String get notifyHighValue => 'Notifier les transactions à haute valeur';

  @override
  String get debtPaymentAlerts => 'Alertes paiements de dettes';

  @override
  String get notifyCustomerPays => 'Notifier quand un client paye';

  @override
  String get staffLoginAlerts => 'Alertes connexion personnel';

  @override
  String get notifyStaffSignIn => 'Notifier quand le personnel se connecte';

  @override
  String get largeSaleThresholdLabel => 'Seuil de grosse vente';

  @override
  String get salesAboveThisAmount =>
      'Les ventes au-dessus de ce montant déclenchent une alerte';

  @override
  String get largeSaleThresholdTitle => 'Seuil de grosse vente';

  @override
  String get youWillBeAlerted =>
      'Vous serez alerté quand une vente dépasse ce montant';

  @override
  String get currentThreshold => 'Seuil actuel';

  @override
  String get quickSelect => 'Sélection rapide';

  @override
  String get customAmount => 'Montant personnalisé';

  @override
  String get pushNotifications => 'Notifications push';

  @override
  String get pushNotifDescription =>
      'Vous recevez des alertes push instantanées quand le propriétaire ajoute, met à jour ou supprime des produits. Ces notifications sont gérées par votre appareil.';

  @override
  String get newProductsAdded => 'Nouveaux produits ajoutés';

  @override
  String get priceStockUpdates => 'Mises à jour prix / stock';

  @override
  String get productsRemoved => 'Produits supprimés';

  @override
  String get about => 'À propos';

  @override
  String get version => 'Version';

  @override
  String get contactSupport => 'Contacter le support';

  @override
  String get getHelpOrReport => 'Obtenir de l\'aide ou signaler un problème';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get howWeHandleData => 'Comment nous gérons vos données';

  @override
  String get termsOfService => 'Conditions d\'utilisation';

  @override
  String get usageTerms => 'Conditions générales d\'utilisation';

  @override
  String get languageAutoDetected =>
      'Détectée automatiquement depuis votre appareil';

  @override
  String get skip => 'Passer';

  @override
  String get next => 'Suivant';

  @override
  String get getStarted => 'Commencer';

  @override
  String get onboarding1Title => 'Bienvenue sur ShopKeeper';

  @override
  String get onboarding1Description =>
      'Votre solution complète de gestion de boutique — conçue pour des commerces comme le vôtre.';

  @override
  String get onboarding2Title => 'Inventaire intelligent';

  @override
  String get onboarding2Description =>
      'Sachez toujours ce que vous avez. Ne manquez jamais de l\'essentiel.';

  @override
  String get onboarding3Title => 'Enregistrez les ventes rapidement';

  @override
  String get onboarding3Description =>
      'Saisissez les ventes au comptant et à crédit en quelques secondes. Les totaux journaliers se mettent à jour automatiquement.';

  @override
  String get onboarding4Title => 'Gérez les dettes clients';

  @override
  String get onboarding4Description =>
      'Suivez qui doit quoi, signalez les comptes à risque et enregistrez les paiements sur le moment.';

  @override
  String get onboarding5Title => 'Analyses par l\'IA';

  @override
  String get onboarding5Description =>
      'Posez n\'importe quelle question à votre assistant IA. Obtenez des rapports hebdomadaires et des recommandations.';

  @override
  String get onboardingFeatureLiveStock => 'Niveaux de stock en temps réel';

  @override
  String get onboardingFeatureLowStockAlerts => 'Alertes stock faible';

  @override
  String get onboardingFeatureRisk => 'Catégorisation des risques';

  @override
  String get onboardingFeatureQuickSale => 'Saisie rapide des ventes';

  @override
  String get onboardingFeatureHistory => 'Historique complet des transactions';

  @override
  String get onboardingFeatureReports =>
      'Rapports journaliers et hebdomadaires';

  @override
  String get onboardingFeatureProfiles => 'Profils clients';

  @override
  String get onboardingFeatureRiskScoring => 'Score de risque';

  @override
  String get onboardingFeaturePaymentTracking => 'Suivi des paiements';

  @override
  String get onboardingFeatureWeekly => 'Résumés hebdomadaires';

  @override
  String get onboardingFeatureAnomaly => 'Détection d\'anomalies';

  @override
  String get onboardingFeatureChat => 'Chat en langage naturel';

  @override
  String get shopkeeperAI => 'ShopKeeper IA';

  @override
  String get poweredByGroq => 'Propulsé par Groq';

  @override
  String get clearChat => 'Effacer la conversation';

  @override
  String get startNewChat => 'Nouvelle conversation';

  @override
  String get deleteConversation =>
      'Cela supprimera tout votre historique de conversation.';

  @override
  String get howCanIHelp => 'Comment puis-je vous aider ?';

  @override
  String get askAboutSales =>
      'Posez-moi des questions sur vos ventes, votre inventaire ou\ndes analyses pour votre boutique.';

  @override
  String get suggested => 'SUGGESTIONS';

  @override
  String get askAnything => 'Demandez n\'importe quoi sur votre boutique…';

  @override
  String get aiSuggestion1 => 'Résumé des ventes du jour';

  @override
  String get aiSuggestion2 => 'Quoi réapprovisionner ?';

  @override
  String get aiSuggestion3 => 'Meilleurs produits cette semaine';

  @override
  String get aiSuggestion4 => 'Donnez-moi des analyses commerciales';

  @override
  String get weAreHereToHelp =>
      'Nous sommes là pour vous aider — contactez-nous à tout moment';

  @override
  String get getInTouch => 'Nous contacter';

  @override
  String get frequentlyAskedQuestions => 'Questions fréquentes';

  @override
  String get emailSupport => 'Support par e-mail';

  @override
  String get whatsApp => 'WhatsApp';

  @override
  String get fastestBadge => 'Rapide';

  @override
  String get reportABug => 'Signaler un bug';

  @override
  String get helpUsImprove => 'Aidez-nous à améliorer l\'application';

  @override
  String get averageResponseTime => 'Temps de réponse moyen';

  @override
  String get responseTimeDetails =>
      'E-mail : sous 24 h  ·  WhatsApp : sous 2 h';

  @override
  String get wellGetBackWithin24h => 'Nous vous répondrons dans les 24 heures';

  @override
  String get bugTitle => 'Titre du bug';

  @override
  String get bugTitleHint =>
      'Ex. : L\'application plante lors de l\'ajout d\'un produit';

  @override
  String get description => 'Description';

  @override
  String get bugDescriptionHint =>
      'Décrivez ce qui s\'est passé et comment reproduire le problème…';

  @override
  String get sendReport => 'Envoyer le rapport';

  @override
  String get couldNotOpenEmail => 'Impossible d\'ouvrir l\'application e-mail.';

  @override
  String get couldNotOpenWhatsApp => 'Impossible d\'ouvrir WhatsApp.';

  @override
  String get faq1Q => 'Comment ajouter un produit avec plusieurs unités ?';

  @override
  String get faq1A =>
      'Allez dans Produits → Ajouter un produit. Dans la section Unités, ajoutez chaque unité (ex. carton, pack) avec son prix et sa quantité par rapport à l\'unité de base. L\'unité avec « Qté en base = 1 » est votre unité de base — le stock est toujours suivi dans cette unité.';

  @override
  String get faq2Q =>
      'Pourquoi les alertes de connexion du personnel n\'apparaissent-elles pas ?';

  @override
  String get faq2A =>
      'Assurez-vous que « Alertes connexion personnel » est activé dans Paramètres → Préférences d\'alertes. Vérifiez aussi que le membre du personnel a un identifiant de boutique et que votre token FCM est enregistré.';

  @override
  String get faq3Q => 'Comment le stock est-il calculé ?';

  @override
  String get faq3A =>
      'Le stock est toujours stocké en unités de base. Lors d\'une vente, la quantité vendue (dans l\'unité choisie) est multipliée par la « quantité en base » de cette unité et déduite du stock. Le tableau de bord affiche les disponibilités dans chaque unité.';

  @override
  String get faq4Q => 'Puis-je modifier le seuil de grosse vente ?';

  @override
  String get faq4A =>
      'Oui — allez dans Paramètres → Préférences d\'alertes et touchez la ligne « Seuil de grosse vente ». Entrez le montant en FCFA au-dessus duquel une vente doit déclencher une alerte.';

  @override
  String get faq5Q => 'Comment créer un compte pour un employé ?';

  @override
  String get faq5A =>
      'Depuis votre profil, touchez « Ajouter un membre du personnel ». Remplissez son nom, son e-mail et son numéro de téléphone. Son numéro de téléphone servira de mot de passe.';

  @override
  String get lastUpdatedJune2026 => 'Dernière mise à jour : juin 2026';

  @override
  String get privacyPolicyIntro =>
      'ShopKeeper s\'engage à protéger votre vie privée. Cette politique explique les données que nous collectons, leur utilisation et vos droits en tant qu\'utilisateur.';

  @override
  String get privacySec1Title => 'Informations collectées';

  @override
  String get privacySec1B1 =>
      'Informations de compte : nom, adresse e-mail et rôle (propriétaire ou employé).';

  @override
  String get privacySec1B2 =>
      'Données de boutique : catalogue de produits, ventes, dettes clients et niveaux de stock.';

  @override
  String get privacySec1B3 =>
      'Informations sur l\'appareil : token FCM pour les notifications push.';

  @override
  String get privacySec1B4 =>
      'Données d\'utilisation : journaux d\'activité pour le débogage et l\'amélioration du service.';

  @override
  String get privacySec2Title => 'Utilisation de vos données';

  @override
  String get privacySec2B1 =>
      'Pour vous authentifier et sécuriser votre compte.';

  @override
  String get privacySec2B2 =>
      'Pour synchroniser vos données de boutique entre sessions et appareils.';

  @override
  String get privacySec2B3 =>
      'Pour envoyer des notifications push pertinentes (alertes stock, ventes, dettes).';

  @override
  String get privacySec2B4 => 'Pour générer des analyses IA sur demande.';

  @override
  String get privacySec2B5 =>
      'Pour améliorer l\'application et corriger les problèmes.';

  @override
  String get privacySec3Title => 'Stockage et sécurité';

  @override
  String get privacySec3B1 =>
      'Vos données sont stockées sur des serveurs sécurisés avec des connexions chiffrées (HTTPS).';

  @override
  String get privacySec3B2 =>
      'Les mots de passe sont hachés avec bcrypt — nous ne les stockons jamais en clair.';

  @override
  String get privacySec3B3 =>
      'Les tokens d\'authentification sont chiffrés localement sur votre appareil.';

  @override
  String get privacySec3B4 => 'Nous ne vendons pas vos données à des tiers.';

  @override
  String get privacySec4Title => 'Services tiers';

  @override
  String get privacySec4B1 =>
      'Firebase Cloud Messaging (FCM) — pour les notifications push. La politique de confidentialité de Google s\'applique.';

  @override
  String get privacySec4B2 =>
      'MongoDB Atlas — pour le stockage cloud. La politique de confidentialité de MongoDB s\'applique.';

  @override
  String get privacySec4B3 =>
      'Nous n\'utilisons pas de réseaux publicitaires ni de plateformes d\'analyse.';

  @override
  String get privacySec5Title => 'Vos droits';

  @override
  String get privacySec5B1 =>
      'Accès : vous pouvez demander une copie de vos données à tout moment.';

  @override
  String get privacySec5B2 =>
      'Correction : vous pouvez mettre à jour vos informations dans l\'application.';

  @override
  String get privacySec5B3 =>
      'Suppression : vous pouvez demander la suppression de votre compte et de vos données en contactant le support.';

  @override
  String get privacySec5B4 =>
      'Portabilité : vos données de ventes et d\'inventaire peuvent être exportées sur demande.';

  @override
  String get privacySec6Title => 'Conservation des données';

  @override
  String get privacySec6B1 =>
      'Les données de compte actif sont conservées tant que votre compte existe.';

  @override
  String get privacySec6B2 =>
      'Après suppression du compte, les données sont effacées dans les 30 jours.';

  @override
  String get privacySec6B3 =>
      'Des données agrégées anonymisées peuvent être conservées à des fins analytiques.';

  @override
  String get privacySec7Title => 'Contact';

  @override
  String get privacySec7B1 =>
      'Pour toute question relative à la confidentialité, contactez-nous à :';

  @override
  String get privacySec7B2 => 'privacy@shopkeeper.cm';

  @override
  String get privacySec7B3 => 'Nous répondons dans les 5 jours ouvrables.';

  @override
  String get termsOfServiceIntro =>
      'En utilisant ShopKeeper, vous acceptez ces conditions. Veuillez les lire attentivement. Si vous n\'êtes pas d\'accord, veuillez cesser d\'utiliser l\'application.';

  @override
  String get termsSec1Title => 'Acceptation des conditions';

  @override
  String get termsSec1B1 =>
      'En créant un compte ou en utilisant ShopKeeper, vous confirmez avoir au moins 18 ans.';

  @override
  String get termsSec1B2 =>
      'Vous acceptez d\'utiliser l\'application uniquement à des fins légitimes de gestion commerciale.';

  @override
  String get termsSec1B3 =>
      'Ces conditions peuvent être mises à jour périodiquement. L\'utilisation continue constitue une acceptation.';

  @override
  String get termsSec2Title => 'Responsabilités du compte';

  @override
  String get termsSec2B1 =>
      'Vous êtes responsable de la confidentialité de vos identifiants de connexion.';

  @override
  String get termsSec2B2 =>
      'Vous ne devez pas partager votre compte propriétaire avec des personnes non autorisées.';

  @override
  String get termsSec2B3 =>
      'Vous êtes responsable de toutes les activités effectuées sous votre compte.';

  @override
  String get termsSec2B4 =>
      'Signalez immédiatement tout accès non autorisé présumé au support.';

  @override
  String get termsSec3Title => 'Utilisation autorisée';

  @override
  String get termsSec3B1 =>
      'ShopKeeper ne peut être utilisé qu\'à des fins légitimes de gestion de boutique et d\'inventaire.';

  @override
  String get termsSec3B2 =>
      'Vous ne devez pas utiliser l\'application pour enregistrer des transactions frauduleuses.';

  @override
  String get termsSec3B3 =>
      'Vous ne devez pas tenter de décompiler, pirater ou abuser du service.';

  @override
  String get termsSec3B4 =>
      'L\'accès automatisé (bots, robots d\'exploration) est strictement interdit.';

  @override
  String get termsSec4Title => 'Propriété des données';

  @override
  String get termsSec4B1 =>
      'Vous conservez la pleine propriété de toutes les données commerciales que vous saisissez dans ShopKeeper.';

  @override
  String get termsSec4B2 =>
      'En utilisant le service, vous nous accordez une licence limitée pour stocker et traiter vos données afin de fournir le service.';

  @override
  String get termsSec4B3 =>
      'Nous ne revendiquons pas la propriété de votre catalogue, de vos ventes ni de vos données clients.';

  @override
  String get termsSec5Title => 'Disponibilité du service';

  @override
  String get termsSec5B1 =>
      'Nous visons une haute disponibilité mais ne garantissons pas un service ininterrompu.';

  @override
  String get termsSec5B2 =>
      'La maintenance planifiée sera communiquée à l\'avance dans la mesure du possible.';

  @override
  String get termsSec5B3 =>
      'Nous ne sommes pas responsables des pertes causées par des interruptions de service hors de notre contrôle.';

  @override
  String get termsSec6Title => 'Limitation de responsabilité';

  @override
  String get termsSec6B1 =>
      'ShopKeeper est fourni « tel quel » sans garantie d\'aucune sorte.';

  @override
  String get termsSec6B2 =>
      'Nous ne sommes pas responsables des décisions commerciales prises sur la base des données de l\'application.';

  @override
  String get termsSec6B3 =>
      'Notre responsabilité totale pour toute réclamation ne dépassera pas le montant payé pour le service au cours des 3 mois précédents.';

  @override
  String get termsSec7Title => 'Résiliation';

  @override
  String get termsSec7B1 =>
      'Vous pouvez cesser d\'utiliser ShopKeeper et demander la suppression de votre compte à tout moment.';

  @override
  String get termsSec7B2 =>
      'Nous nous réservons le droit de suspendre ou résilier les comptes qui violent ces conditions.';

  @override
  String get termsSec7B3 =>
      'Lors de la résiliation, vos données seront supprimées dans les 30 jours conformément à notre politique de confidentialité.';

  @override
  String get termsSec8Title => 'Droit applicable';

  @override
  String get termsSec8B1 =>
      'Ces conditions sont régies par les lois de la République du Cameroun.';

  @override
  String get termsSec8B2 =>
      'Tout litige sera d\'abord résolu par une négociation de bonne foi.';

  @override
  String get termsSec8B3 =>
      'Pour toute question, contactez-nous à : legal@shopkeeper.cm';

  @override
  String get myProfile => 'Mon profil';

  @override
  String get shopNameLabel => 'Nom de la boutique';

  @override
  String get ownerName => 'Nom du propriétaire';

  @override
  String get shopDescription => 'Description de la boutique';

  @override
  String get statusLabel => 'Statut';

  @override
  String get roleLabel => 'Rôle';

  @override
  String get shopLabel => 'Boutique';

  @override
  String get verified => 'Vérifié';

  @override
  String get assigned => 'Assigné';

  @override
  String get unassigned => 'Non assigné';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get signOutQuestion => 'Se déconnecter ?';

  @override
  String get signOutDescription => 'Se déconnecter de votre compte ShopKeeper';

  @override
  String get ownerSignOutSubtitle =>
      'Vous devrez vous reconnecter pour accéder à votre compte.';

  @override
  String get staffSignOutSubtitle =>
      'Vous aurez besoin de votre e-mail et de votre numéro de téléphone pour vous reconnecter.';

  @override
  String get staffName => 'Nom de l\'employé';

  @override
  String get actions => 'Actions';

  @override
  String get createLoginCredentialsForNewStaff =>
      'Créer les identifiants de connexion pour le nouveau personnel';

  @override
  String get managePreferencesAndSecurity =>
      'Gérer les préférences et la sécurité';

  @override
  String get manageAppPreferences => 'Gérer les préférences de l\'application';

  @override
  String get editShopDetails => 'Modifier les détails de la boutique';

  @override
  String get editShopSubtitle =>
      'Mettre à jour le nom et la description de la boutique';

  @override
  String get editShop => 'Modifier la boutique';

  @override
  String get shopUpdatedSuccessfully => 'Boutique mise à jour avec succès';

  @override
  String get createNewShop => 'Créer une nouvelle boutique';

  @override
  String get createNewShopSubtitle =>
      'Enregistrer une boutique supplémentaire pour votre compte';

  @override
  String get hintExShopDescription => 'ex. Votre épicerie du quotidien';

  @override
  String get yourShops => 'Vos boutiques';

  @override
  String get switchShop => 'Changer';

  @override
  String switchedToShop(String name) {
    return 'Basculé sur $name';
  }

  @override
  String switchingToShop(String name) {
    return 'Changement vers $name';
  }
}
