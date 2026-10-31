/// Все тексты интерфейса в одном месте.
class AppStrings {
  // навигация
  static const String navCalc = 'Расчёт';
  static const String navHistory = 'История';
  static const String navSettings = 'Настройки';

  // общее
  static const String cancel = 'Отмена';
  static const String save = 'Сохранить';
  static const String share = 'Поделиться';
  static const String reset = 'Сбросить';
  static const String delete = 'Удалить';
  static const String errGeneric = 'Что-то пошло не так';
  static const String errPositive = 'Введите число больше нуля';
  static const String errPercent = 'Введите число от 0 до 100';

  // калькулятор
  static const String fieldPrice = 'Цена за 1 шт';
  static const String fieldQty = 'Количество';
  static const String fieldWeight = 'Вес 1 шт';
  static const String fieldCategory = 'Категория';
  static const String fieldRate = 'Курс ¥→₽';
  static const String fieldCommission = 'Комиссия';
  static const String fieldDelivery = 'Доставка';
  static const String fieldExtra = 'Доп. расходы';
  static const String total = 'Итого';
  static const String goods = 'Товары';
  static const String commission = 'Комиссия';
  static const String delivery = 'Доставка';
  static const String extra = 'Доп. расходы';
  static const String perItem = 'За 1 шт';
  static const String saved = 'Сохранено';
  static const String enterPrice = 'Введите цену товара';
  static const String saveDialogTitle = 'Сохранить расчёт';
  static const String saveDialogLabel = 'Название (необязательно)';
  static const String chooseCategory = 'Категория';
  static const String rateEdited = 'Курс изменён вручную';
  static const String rateManual = 'Курс: вручную';
  static const String rateUnavailable =
      'Курс ЦБ недоступен, используется ручной';
  static const String rateNotUpdated = 'не обновлён';
  static const String rateReset = 'Сбросить курс';
  static const String rateRefresh = 'Обновить курс';
  static const String rateUpdateFailed = 'Не удалось обновить курс';

  // история
  static const String historyTitle = 'История';
  static const String historyEmpty = 'Здесь появятся ваши расчёты';
  static const String historyEmptyHint =
      'Сохраните первый расчёт на вкладке «Расчёт»';
  static const String clearAll = 'Очистить';
  static const String clearConfirmTitle = 'Очистить историю?';
  static const String clearConfirmText = 'Все сохранённые расчёты будут удалены.';
  static const String undo = 'Отменить';
  static const String deleted = 'Расчёт удалён';
  static const String pcs = 'шт';
  static const String pasteToCalc = 'Вставить в калькулятор';
  static const String detailsInput = 'Исходные данные';
  static const String detailsResult = 'Расчёт';
  static const String detailsWeight = 'Вес 1 шт';
  static const String detailsPerKg = 'Доставка за кг';

  // настройки
  static const String settingsTitle = 'Настройки';
  static const String sectionRate = 'Курс';
  static const String modeManual = 'Ручной';
  static const String modeAuto = 'Авто (ЦБ)';
  static const String markup = 'Наценка к курсу';
  static const String cbrRate = 'Курс ЦБ';
  static const String cbrNone = 'Курса пока нет';
  static const String updatedAt = 'Обновлён';
  static const String defaultCommission = 'Комиссия по умолчанию';
  static const String sectionCommission = 'Комиссия';
  static const String sectionCategories = 'Категории';
  static const String addCategory = 'Новая';
  static const String editCategory = 'Категория';
  static const String categoryName = 'Название';
  static const String categoryPrice = 'Цена доставки';
  static const String resetCategories = 'Сбросить категории';
  static const String resetCategoriesTitle = 'Сбросить категории?';
  static const String resetCategoriesText =
      'Список вернётся к 5 стартовым категориям. Свои категории и цены будут удалены.';
  static const String sectionTheme = 'Тема';
  static const String themeDark = 'Тёмная';
  static const String themeLight = 'Светлая';
  static const String themeSystem = 'Система';
  static const String sectionKitex = 'KITex';
  static const String sectionCompany = 'Ваша компания';
  static const String companyHint =
      'Название и контакт попадут в текст «Поделиться»';
  static const String companyName = 'Название компании';
  static const String companyContact = 'Контакт (Telegram, телефон)';
  static const String rateFailedToast =
      'Не удалось обновить курс. Используется последний';
  static const String kitexTagline =
      'Инструмент, которым пользуется торговая сеть KITex';
  static const String linkFailed = 'Не удалось открыть ссылку';
}
