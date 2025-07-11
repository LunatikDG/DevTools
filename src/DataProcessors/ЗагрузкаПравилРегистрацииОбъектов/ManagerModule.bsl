///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

// Инициализирует колонки таблицы правил регистрации объектов.
// 
// Возвращаемое значение:
//  ТаблицаЗначений:
//    * ОбъектНастройки - Строка
//    * ОбъектМетаданныхИмя - Строка
//    * ИмяПланаОбмена - Строка
//    * ИмяРеквизитаФлага - Строка
//    * ТекстЗапроса - Строка
//    * СвойстваОбъекта - Структура
//    * СвойстваОбъектаСтрокой - Строка
//    * ПравилоПоСвойствамОбъектаПустое - Булево
//    * ОтборПоСвойствамПланаОбмена - ДеревоЗначений из см.ИнициализацияТаблицыОтборПоСвойствамПланаОбмена 
//    * ОтборПоСвойствамОбъекта - ДеревоЗначений из см.ИнициализацияТаблицыОтборПоСвойствамОбъекта 
//    * ПередОбработкой - Строка
//    * ПриОбработке - Строка
//    * ПриОбработкеДополнительный - Строка
//    * ПослеОбработки - Строка
//    * ЕстьОбработчикПередОбработкой - Булево
//    * ЕстьОбработчикПриОбработке - Булево
//    * ЕстьОбработчикПриОбработкеДополнительный - Булево
//    * ЕстьОбработчикПослеОбработки - Булево
//
Функция ИнициализацияТаблицыПРО() Экспорт
	
	ПравилаРегистрацииОбъектов = Новый ТаблицаЗначений;
	
	Колонки = ПравилаРегистрацииОбъектов.Колонки;
	
	Колонки.Добавить("ОбъектНастройки");
	
	Колонки.Добавить("ОбъектМетаданныхИмя", Новый ОписаниеТипов("Строка"));
	Колонки.Добавить("ИмяПланаОбмена",      Новый ОписаниеТипов("Строка"));
	
	Колонки.Добавить("ИмяРеквизитаФлага", Новый ОписаниеТипов("Строка"));
	
	Колонки.Добавить("ТекстЗапроса",    Новый ОписаниеТипов("Строка"));
	Колонки.Добавить("СвойстваОбъекта", Новый ОписаниеТипов("Структура"));
	
	Колонки.Добавить("СвойстваОбъектаСтрокой", Новый ОписаниеТипов("Строка"));
	
	// Признаки того, что правила пустые.
	Колонки.Добавить("ПравилоПоСвойствамОбъектаПустое",     Новый ОписаниеТипов("Булево"));
	
	Колонки.Добавить("ОтборПоСвойствамПланаОбмена", Новый ОписаниеТипов("ДеревоЗначений"));
	Колонки.Добавить("ОтборПоСвойствамОбъекта",     Новый ОписаниеТипов("ДеревоЗначений"));
	
	// обработчики событий
	Колонки.Добавить("ПередОбработкой",            Новый ОписаниеТипов("Строка"));
	Колонки.Добавить("ПриОбработке",               Новый ОписаниеТипов("Строка"));
	Колонки.Добавить("ПриОбработкеДополнительный", Новый ОписаниеТипов("Строка"));
	Колонки.Добавить("ПослеОбработки",             Новый ОписаниеТипов("Строка"));
	
	Колонки.Добавить("ЕстьОбработчикПередОбработкой",            Новый ОписаниеТипов("Булево"));
	Колонки.Добавить("ЕстьОбработчикПриОбработке",               Новый ОписаниеТипов("Булево"));
	Колонки.Добавить("ЕстьОбработчикПриОбработкеДополнительный", Новый ОписаниеТипов("Булево"));
	Колонки.Добавить("ЕстьОбработчикПослеОбработки",             Новый ОписаниеТипов("Булево"));
	
	Возврат ПравилаРегистрацииОбъектов;
	
КонецФункции

// Инициализирует колонки таблицы правил регистрации по свойствам плана обмена.
// 
// Возвращаемое значение:
//  ДеревоЗначений:
//    * ЭтоГруппа - Булево
//    * БулевоЗначениеГруппы - Строка
//    * СвойствоОбъекта - Строка
//    * ВидСравнения - Строка
//    * ЭтоСтрокаКонстанты - Булево
//    * ТипСвойстваОбъекта - Строка
//    * ПараметрУзла - Строка
//    * ТабличнаяЧастьПараметраУзла - Строка
//    * ЗначениеКонстанты - Произвольный
//
Функция ИнициализацияТаблицыОтборПоСвойствамПланаОбмена() Экспорт
	
	ШаблонДерева = Новый ДеревоЗначений;
	
	Колонки = ШаблонДерева.Колонки;
	
	Колонки.Добавить("ЭтоГруппа",            Новый ОписаниеТипов("Булево"));
	Колонки.Добавить("БулевоЗначениеГруппы", Новый ОписаниеТипов("Строка"));
	
	Колонки.Добавить("СвойствоОбъекта",      Новый ОписаниеТипов("Строка"));
	Колонки.Добавить("ВидСравнения",         Новый ОписаниеТипов("Строка"));
	Колонки.Добавить("ЭтоСтрокаКонстанты",   Новый ОписаниеТипов("Булево"));
	Колонки.Добавить("ТипСвойстваОбъекта",   Новый ОписаниеТипов("Строка"));
	
	Колонки.Добавить("ПараметрУзла",                Новый ОписаниеТипов("Строка"));
	Колонки.Добавить("ТабличнаяЧастьПараметраУзла", Новый ОписаниеТипов("Строка"));
	
	Колонки.Добавить("ЗначениеКонстанты"); // произвольный тип
	
	Возврат ШаблонДерева;
	
КонецФункции

// Инициализирует колонки таблицы правил регистрации по свойствам объекта.
// 
// Возвращаемое значение:
//  ДеревоЗначений:
//    * ЭтоГруппа - Булево
//    * ЭтоОператорИ - Булево
//    * СвойствоОбъекта - Строка
//    * КлючСвойстваОбъекта - Строка
//    * ВидСравнения - Строка
//    * ТипСвойстваОбъекта - Строка
//    * ВидЭлементаОтбора - Строка
//    * ЗначениеКонстанты - Произвольный
//    * ЗначениеСвойства - Произвольный
//
Функция ИнициализацияТаблицыОтборПоСвойствамОбъекта() Экспорт
	
	ШаблонДерева = Новый ДеревоЗначений;
	
	Колонки = ШаблонДерева.Колонки;
	
	Колонки.Добавить("ЭтоГруппа",           Новый ОписаниеТипов("Булево"));
	Колонки.Добавить("ЭтоОператорИ",        Новый ОписаниеТипов("Булево"));
	
	Колонки.Добавить("СвойствоОбъекта",     Новый ОписаниеТипов("Строка"));
	Колонки.Добавить("КлючСвойстваОбъекта", Новый ОписаниеТипов("Строка"));
	Колонки.Добавить("ВидСравнения",        Новый ОписаниеТипов("Строка"));
	Колонки.Добавить("ТипСвойстваОбъекта",  Новый ОписаниеТипов("Строка"));
	Колонки.Добавить("ВидЭлементаОтбора",   Новый ОписаниеТипов("Строка"));
	
	Колонки.Добавить("ЗначениеКонстанты"); // произвольный тип
	Колонки.Добавить("ЗначениеСвойства");  // произвольный тип
	
	Возврат ШаблонДерева;
	
КонецФункции

#КонецОбласти

#КонецЕсли