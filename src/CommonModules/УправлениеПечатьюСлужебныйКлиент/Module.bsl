///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// Обработчик подключенной команды.
//
// Параметры:
//   МассивСсылок - Массив из ЛюбаяСсылка - ссылки выбранных объектов, для которых выполняется команда.
//   ПараметрыВыполнения - см. ПодключаемыеКомандыКлиент.ПараметрыВыполненияКоманды
//
Процедура ОбработчикКоманды(Знач МассивСсылок, Знач ПараметрыВыполнения) Экспорт
	ПараметрыВыполнения.Вставить("ОбъектыПечати", МассивСсылок);
	ОписаниеКоманды = ПараметрыВыполнения.ОписаниеКоманды;
	ОбщегоНазначенияКлиентСервер.ДополнитьСтруктуру(ОписаниеКоманды, ОписаниеКоманды.ДополнительныеПараметры, Истина);
	
	Если ОписаниеКоманды.КомандаПоУмолчанию Тогда
		ПараметрыПечатиПоУмолчанию = УправлениеПечатьюВызовСервера.ПараметрыВыполненияДляПечатиПоУмолчанию(МассивСсылок);
		Если ПараметрыПечатиПоУмолчанию.ЕстьПараметрыВыполнения Тогда
			Для Каждого НовыеПараметры Из ПараметрыПечатиПоУмолчанию.НовыеПараметрыВыполнения Цикл
				ЗаполнитьЗначенияСвойств(ПараметрыВыполнения, НовыеПараметры);
				ВыполнитьПодключаемуюКомандуПечатиЗавершение(Истина, ПараметрыВыполнения);
			КонецЦикла;
		Иначе
			НовыеПараметры = ПараметрыПечатиПоУмолчанию.НовыеПараметрыВыполнения[0];
			СписокКоманд = НовыеПараметры.КомандыДляВыбора;
			
			ПараметрыОповещения = Новый Структура;
			ПараметрыОповещения.Вставить("ОписанияКоманд", НовыеПараметры.ОписанияКоманд);
			ПараметрыОповещения.Вставить("ПараметрыВыполнения", ПараметрыВыполнения);
			
			Оповещение = Новый ОписаниеОповещения("ПослеВыбораКомандыПоУмолчанию", ЭтотОбъект, ПараметрыОповещения);
			Если СписокКоманд.Количество() = 1 Тогда
				ВыполнитьОбработкуОповещения(Оповещение, СписокКоманд[0]);
			Иначе
				СписокКоманд.ПоказатьВыборЭлемента(Оповещение, НСтр("ru = 'Выбор печатной формы'"));
			КонецЕсли;
		КонецЕсли;
	Иначе
		Оповещение = Новый ОписаниеОповещения("ПродолжитьВыполнениеОбработчикКоманды", ЭтотОбъект, ПараметрыВыполнения);
		УправлениеПечатьюКлиент.ПередНачаломВыполненияКомандыПечати(МассивСсылок, ПараметрыВыполнения.ОписаниеКоманды, Оповещение);
	КонецЕсли;
КонецПроцедуры

// Формирует табличный документ в форме подсистемы "Печать".
Процедура ВыполнитьОткрытиеПечатнойФормы(ИсточникДанных, ИдентификаторКоманды, ОбъектыНазначения, Форма, СтандартнаяОбработка) Экспорт
	
	Параметры = Новый Структура;
	Параметры.Вставить("Форма",                Форма);
	Параметры.Вставить("ИсточникДанных",       ИсточникДанных);
	Параметры.Вставить("ИдентификаторКоманды", ИдентификаторКоманды);
	
	ВыполнитьОткрытиеПечатнойФормыЗавершение(ОбъектыНазначения, Параметры);
	
КонецПроцедуры

// Открывает форму настроек видимости команд в подменю "Печать".
Процедура ОткрытьФормуНастроекПодменюПечать(Отбор) Экспорт
	ПараметрыОткрытия = Новый Структура;
	ПараметрыОткрытия.Вставить("Отбор", Отбор);
	ОткрытьФорму("ОбщаяФорма.НастройкаКомандПечати", ПараметрыОткрытия, , , , , , РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
КонецПроцедуры

// Открыть форму для выбора вариантов формата вложений.
//
// Параметры:
//  НастройкиФормата - Структура:
//       * УпаковатьВАрхив   - Булево - признак необходимости упаковки вложений в архив.
//       * ФорматыСохранения - Массив - список выбранных форматов вложений.
//  Оповещение       - ОписаниеОповещения - оповещение, которое вызывается после закрытие формы для обработки
//                                          результатов выбора.
//
Процедура ОткрытьФормуВыбораФорматаВложений(НастройкиФормата, Оповещение) Экспорт
	ПараметрыФормы = Новый Структура("НастройкиФормата", НастройкиФормата);
	ОбщегоНазначенияКлиент.ПоказатьВыборФорматаВложений(Оповещение, НастройкиФормата);
КонецПроцедуры

// Открыть форму подготовки нового письма.
// 
// Параметры:
//  ФормаВладелец  - ФормаКлиентскогоПриложения 
//  ПараметрыФормы - Структура:
//    * Получатель - Строка - список адресов в формате:
//                           [ПредставлениеПолучателя1] <Адрес1>; [[ПредставлениеПолучателя2] <Адрес2>;...]
//                 - СписокЗначений:
//                     ** Представление - Строка - представление получателя,
//                     ** Значение      - Строка - почтовый адрес.
//                 - Массив - массив структур, описывающий получателей:
//                     ** Адрес                        - Строка - почтовый адрес получателя сообщения;
//                     ** Представление                - Строка - представление адресата;
//                     ** ИсточникКонтактнойИнформации - СправочникСсылка - владелец контактной информации. 
//  ОписаниеОповещенияОЗавершении - ОписаниеОповещения
//
Процедура ОткрытьФормуПодготовкиНовогоПисьма(ФормаВладелец, ПараметрыФормы, ОписаниеОповещенияОЗавершении) Экспорт
	ОткрытьФорму("ОбщаяФорма.ПодготовкаНовогоПисьма", ПараметрыФормы, ФормаВладелец,,,, ОписаниеОповещенияОЗавершении);
КонецПроцедуры

Функция ПараметрыОткрытияФормыПечати() Экспорт
	ПараметрыОткрытия = Новый Структура("ИмяМенеджераПечати,ИменаМакетов,ПараметрКоманды,ПараметрыПечати,УникальныйИдентификаторХранилища,
	|ИсточникДанных,КоллекцияПечатныхФорм,ПараметрыИсточника,ТекущийЯзык,ВладелецФормы,ПараметрыВывода");
	ПараметрыОткрытия.Вставить("ОбъектыПечати", Новый СписокЗначений);
	Возврат ПараметрыОткрытия;
КонецФункции  

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ВыполнитьПодключаемуюКомандуПечатиЗавершение(РасширениеРаботыСФайламиПодключено, ДополнительныеПараметры)
	
	Если Не РасширениеРаботыСФайламиПодключено Тогда
		Возврат;
	КонецЕсли;
	
	ОписаниеКоманды = ДополнительныеПараметры.ОписаниеКоманды;
	Форма = ДополнительныеПараметры.Форма;
	ОбъектыПечати = ДополнительныеПараметры.ОбъектыПечати;
	
	ОписаниеКоманды = ОбщегоНазначенияКлиент.СкопироватьРекурсивно(ОписаниеКоманды);
	ОписаниеКоманды.Вставить("ОбъектыПечати", ОбъектыПечати);
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ОценкаПроизводительности") Тогда
		МодульОценкаПроизводительностиКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ОценкаПроизводительностиКлиент");
		
		ИмяПоказателя = НСтр("ru = 'Печать'") + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку("/%1/%2/%3/%4/%5/%6/%7",
			ОписаниеКоманды.Идентификатор,
			ОписаниеКоманды.МенеджерПечати,
			ОписаниеКоманды.Обработчик,
			Формат(ОписаниеКоманды.ОбъектыПечати.Количество(), "ЧГ=0"),
			?(ОписаниеКоманды.СразуНаПринтер, "Принтер", ""),
			ОписаниеКоманды.ФорматСохранения,
			?(ОписаниеКоманды.ФиксированныйКомплект, "Фиксированный", ""));
		
		МодульОценкаПроизводительностиКлиент.НачатьЗамерВремениТехнологический(Истина, НРег(ИмяПоказателя));
	КонецЕсли;
	
	Если ОписаниеКоманды.МенеджерПечати = "СтандартныеПодсистемы.ДополнительныеОтчетыИОбработки" 
		И ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ДополнительныеОтчетыИОбработки") Тогда
			МодульДополнительныеОтчетыИОбработкиКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ДополнительныеОтчетыИОбработкиКлиент");
			МодульДополнительныеОтчетыИОбработкиКлиент.ВыполнитьНазначаемуюКомандуПечати(ОписаниеКоманды, Форма);
			Возврат;
	КонецЕсли;
	
	Если Не ПустаяСтрока(ОписаниеКоманды.Обработчик) Тогда
		ОписаниеКоманды.Вставить("Форма", Форма);
		ИмяОбработчика = ОписаниеКоманды.Обработчик;
		Если СтрЧислоВхождений(ИмяОбработчика, ".") = 0 И ЭтоОтчетИлиОбработка(ОписаниеКоманды.МенеджерПечати) Тогда
			ОсновнаяФорма = ПолучитьФорму(ОписаниеКоманды.МенеджерПечати + ".Форма", , Форма, Истина);// АПК:65 - форма создается для вызова метода
			ИмяОбработчика = "ОсновнаяФорма." + ИмяОбработчика;
		КонецЕсли;
		ПараметрыПечати = УправлениеПечатьюКлиент.ОписаниеПараметровПечати();
		ЗаполнитьЗначенияСвойств(ПараметрыПечати, ОписаниеКоманды);
		Обработчик = ИмяОбработчика + "(ПараметрыПечати)";
		Результат = Вычислить(Обработчик);
		
		ОписаниеКоманды.Удалить("Форма");
		ОбновитьКоманды(Форма, ОписаниеКоманды);
		
		Возврат;
	КонецЕсли;
	
	Если ОписаниеКоманды.СразуНаПринтер Тогда
		ОписаниеКомандыНаПринтер = Новый Структура("Идентификатор,ОсновнаяПечатнаяФорма,НаименованиеПечатнойФормы,
			|ЗаменитьОсновнуюПечатнуюФорму,ИдентификаторИзКомплекта");
		ЗаполнитьЗначенияСвойств(ОписаниеКомандыНаПринтер, ОписаниеКоманды);
		ОписаниеКоманды.ДополнительныеПараметры.Вставить("ОписаниеКоманды", ОписаниеКомандыНаПринтер);
		УправлениеПечатьюКлиент.ВыполнитьКомандуПечатиНаПринтер(ОписаниеКоманды.МенеджерПечати, ОписаниеКоманды.Идентификатор,
			ОбъектыПечати, ОписаниеКоманды.ДополнительныеПараметры);
	Иначе
		УправлениеПечатьюКлиент.ВыполнитьКомандуПечати(ОписаниеКоманды.МенеджерПечати, ОписаниеКоманды.Идентификатор,
			ОбъектыПечати, Форма, ОписаниеКоманды);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьПроведенностьДокументовДиалогПроведения(Параметры) Экспорт
	
	Если Не Параметры.ЕстьПравоПроведения Тогда
		Если Параметры.НепроведенныеДокументы.Количество() = 1 Тогда
			ТекстПредупреждения = НСтр("ru = 'Для того чтобы распечатать документ, его необходимо предварительно провести. Недостаточно прав для проведения документа, печать невозможна.'");
		Иначе
			ТекстПредупреждения = НСтр("ru = 'Для того чтобы распечатать документы, их необходимо предварительно провести. Недостаточно прав для проведения документов, печать невозможна.'");
		КонецЕсли;
		ВызватьИсключение(ТекстПредупреждения, КатегорияОшибки.НарушениеПравДоступа);
	КонецЕсли;

	Если Параметры.НепроведенныеДокументы.Количество() = 1 Тогда
		ТекстВопроса = НСтр("ru = 'Для того чтобы распечатать документ, его необходимо предварительно провести. Выполнить проведение документа и продолжить?'");
	Иначе
		ТекстВопроса = НСтр("ru = 'Для того чтобы распечатать документы, их необходимо предварительно провести. Выполнить проведение документов и продолжить?'");
	КонецЕсли;
	ОписаниеОповещения = Новый ОписаниеОповещения("ПроверитьПроведенностьДокументовПроведениеДокументов", 
		ЭтотОбъект, Параметры);
	ПоказатьВопрос(ОписаниеОповещения, ТекстВопроса, РежимДиалогаВопрос.ДаНет);
	
КонецПроцедуры

Процедура ПроверитьПроведенностьДокументовПроведениеДокументов(РезультатВопроса, ДополнительныеПараметры) Экспорт
	
	Если РезультатВопроса <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	ОчиститьСообщения();
	ДанныеОНепроведенныхДокументах = ОбщегоНазначенияКлиент.ПровестиДокументы(ДополнительныеПараметры.НепроведенныеДокументы);
	
	ШаблонСообщения = НСтр("ru = 'Документ %1 не проведен: %2'");
	НепроведенныеДокументы = Новый Массив;
	Для Каждого ИнформацияОДокументе Из ДанныеОНепроведенныхДокументах Цикл
		ОбщегоНазначенияКлиент.СообщитьПользователю(
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСообщения, 
			Строка(ИнформацияОДокументе.Ссылка), ИнформацияОДокументе.ОписаниеОшибки),
			ИнформацияОДокументе.Ссылка);
		НепроведенныеДокументы.Добавить(ИнформацияОДокументе.Ссылка);
	КонецЦикла;
	ПроведенныеДокументы = ОбщегоНазначенияКлиентСервер.РазностьМассивов(ДополнительныеПараметры.СписокДокументов, 
		НепроведенныеДокументы);
	ИзмененныеДокументы = ОбщегоНазначенияКлиентСервер.РазностьМассивов(ДополнительныеПараметры.НепроведенныеДокументы, 
		НепроведенныеДокументы);
	
	ДополнительныеПараметры.Вставить("НепроведенныеДокументы", НепроведенныеДокументы);
	ДополнительныеПараметры.Вставить("ПроведенныеДокументы", ПроведенныеДокументы);
	
	ОбщегоНазначенияКлиент.ОповеститьОбИзмененииОбъектов(ИзмененныеДокументы);
	
	// Если команда была вызвана из формы, то зачитываем в форму актуальную (проведенную) копию из базы.
	Если ТипЗнч(ДополнительныеПараметры.Форма) = Тип("ФормаКлиентскогоПриложения") Тогда
		Попытка
			ДополнительныеПараметры.Форма.Прочитать();
		Исключение
			// Если метода Прочитать нет, значит печать выполнена не из формы объекта.
		КонецПопытки;
	КонецЕсли;
		
	Если НепроведенныеДокументы.Количество() > 0 Тогда
		// Спрашиваем пользователя о необходимости продолжения печати при наличии непроведенных документов.
		ТекстДиалога = НСтр("ru = 'Не удалось провести один или несколько документов.'");
		
		КнопкиДиалога = Новый СписокЗначений;
		Если ПроведенныеДокументы.Количество() > 0 Тогда
			ТекстДиалога = ТекстДиалога + " " + НСтр("ru = 'Продолжить?'");
			КнопкиДиалога.Добавить(КодВозвратаДиалога.Пропустить, НСтр("ru = 'Продолжить'"));
			КнопкиДиалога.Добавить(КодВозвратаДиалога.Отмена);
		Иначе
			КнопкиДиалога.Добавить(КодВозвратаДиалога.ОК);
		КонецЕсли;
		
		ОписаниеОповещения = Новый ОписаниеОповещения("ПроверитьПроведенностьДокументовЗавершение", ЭтотОбъект, ДополнительныеПараметры);
		ПоказатьВопрос(ОписаниеОповещения, ТекстДиалога, КнопкиДиалога);
		Возврат;
	КонецЕсли;
	
	ПроверитьПроведенностьДокументовЗавершение(Неопределено, ДополнительныеПараметры);
	
КонецПроцедуры

Процедура ПроверитьПроведенностьДокументовЗавершение(РезультатВопроса, ДополнительныеПараметры) Экспорт
	
	Если РезультатВопроса <> Неопределено И РезультатВопроса <> КодВозвратаДиалога.Пропустить Тогда
		Возврат;
	КонецЕсли;
	
	ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОписаниеПроцедурыЗавершения, ДополнительныеПараметры.ПроведенныеДокументы);
	
КонецПроцедуры

Функция ЭтоОтчетИлиОбработка(МенеджерПечати)
	Если Не ЗначениеЗаполнено(МенеджерПечати) Тогда
		Возврат Ложь;
	КонецЕсли;
	МассивПодстрок = СтрРазделить(МенеджерПечати, ".");
	Если МассивПодстрок.Количество() = 0 Тогда
		Возврат Ложь;
	КонецЕсли;
	Вид = ВРег(СокрЛП(МассивПодстрок[0]));
	Возврат Вид = "ОТЧЕТ" Или Вид = "ОБРАБОТКА";
КонецФункции

Процедура ВыполнитьОткрытиеПечатнойФормыЗавершение(ОбъектыНазначения, ДополнительныеПараметры)
	
	Форма = ДополнительныеПараметры.Форма;
	
	ПараметрыИсточника = Новый Структура;
	ПараметрыИсточника.Вставить("ИдентификаторКоманды", ДополнительныеПараметры.ИдентификаторКоманды);
	ПараметрыИсточника.Вставить("ОбъектыНазначения",    ОбъектыНазначения);
	
	ПараметрыОткрытия = ПараметрыОткрытияФормыПечати();
	ПараметрыОткрытия.Вставить("ИсточникДанных",     ДополнительныеПараметры.ИсточникДанных);
	ПараметрыОткрытия.Вставить("ПараметрыИсточника", ПараметрыИсточника);
	ПараметрыОткрытия.Вставить("ПараметрКоманды", ОбъектыНазначения);
	
	Если Форма = Неопределено Тогда
		ПараметрыОткрытия.УникальныйИдентификаторХранилища = Новый УникальныйИдентификатор;
	Иначе
		ПараметрыОткрытия.УникальныйИдентификаторХранилища = Форма.УникальныйИдентификатор;
	КонецЕсли;

	ИмяПараметра = "СтандартныеПодсистемы.Печать.ВыполнитьКомандуПечати";
	СписокПереданныхПараметров = ПараметрыПриложения[ИмяПараметра];
	
	Если СписокПереданныхПараметров = Неопределено Тогда
		СписокПереданныхПараметров = Новый Массив;
		ПараметрыПриложения[ИмяПараметра] = СписокПереданныхПараметров;
	КонецЕсли;
	
	СписокПереданныхПараметров.Добавить(ПараметрыОткрытия);
	
	ПодключитьОбработчикОжидания("ПродолжитьВыполнениеКомандыПечатиСПереданнымиПараметрами", 0.1, Истина);
	
КонецПроцедуры

Процедура ПродолжитьВыполнениеКомандыПечати() Экспорт
	
	ИмяПараметра = "СтандартныеПодсистемы.Печать.ВыполнитьКомандуПечати";
	СписокПереданныхПараметров = ПараметрыПриложения[ИмяПараметра];
	
	Если СписокПереданныхПараметров = Неопределено Тогда
		СписокПереданныхПараметров = Новый Массив;
		ПараметрыПриложения[ИмяПараметра] = СписокПереданныхПараметров;
		Возврат;
	КонецЕсли;
	
	Если СписокПереданныхПараметров.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыОткрытия = СписокПереданныхПараметров[0];
	ПараметрыПечати = ПараметрыОткрытия.ПараметрыПечати;
	ВладелецФормы = ПараметрыОткрытия.ВладелецФормы;
	ПараметрыОткрытия.ВладелецФормы = Неопределено;
	СписокПереданныхПараметров.Удалить(0);
	ПодключитьОбработчикОжидания("ПродолжитьВыполнениеКомандыПечатиСПереданнымиПараметрами", 0.1, Истина);
	
	Если ТипЗнч(ПараметрыПечати) = Тип("Структура")
		И ПараметрыПечати.Свойство("ВыполнятьВФоновомЗадании")
		И ПараметрыПечати.ВыполнятьВФоновомЗадании = Истина Тогда
		
		ВыполнитьКомандуПечатиВФоне(ВладелецФормы, ПараметрыОткрытия);
	Иначе
		ОткрытьФорму("ОбщаяФорма.ПечатьДокументов", ПараметрыОткрытия, ВладелецФормы, Строка(Новый УникальныйИдентификатор));
		ОбновитьКоманды(ВладелецФормы, ПараметрыПечати);
	КонецЕсли;
	
КонецПроцедуры

Процедура ВыполнитьКомандуПечатиВФоне(ВладелецФормы, ПараметрыОткрытия)
	
	Если ВладелецФормы = Неопределено Тогда
		ПараметрыОткрытия.УникальныйИдентификаторХранилища = Новый УникальныйИдентификатор;
	Иначе
		ПараметрыОткрытия.УникальныйИдентификаторХранилища = ВладелецФормы.УникальныйИдентификатор;
	КонецЕсли;
	
	ДлительнаяОперация = УправлениеПечатьюВызовСервера.НачатьФормированиеПечатныхФорм(ПараметрыОткрытия);
	ПараметрыОткрытия.ВладелецФормы = ВладелецФормы;
	
	ОповещениеОЗавершении = Новый ОписаниеОповещения("ОткрытьФормуПечатьДокументов", ЭтотОбъект, ПараметрыОткрытия);
	ПараметрыОжидания = ПараметрыОжидания(ВладелецФормы);
	ДлительныеОперацииКлиент.ОжидатьЗавершение(ДлительнаяОперация, ОповещениеОЗавершении, ПараметрыОжидания);
	
КонецПроцедуры

// Параметры:
//  Результат - см. ДлительныеОперацииКлиент.НовыйРезультатДлительнойОперации
//  ПараметрыОткрытия - Структура
//
Процедура ОткрытьФормуПечатьДокументов(Результат, ПараметрыОткрытия) Экспорт
	
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Результат.Статус = "Ошибка" Тогда
		СтандартныеПодсистемыКлиент.ВывестиИнформациюОбОшибке(Результат.ИнформацияОбОшибке);
		Возврат;
	КонецЕсли;
	
	СтруктураРезультата = ПолучитьИзВременногоХранилища(Результат.АдресРезультата);
	
	Для Каждого ПечатнаяФорма Из СтруктураРезультата.КоллекцияПечатныхФорм Цикл
		Если ТипЗнч(ПечатнаяФорма.ТабличныйДокумент) = Тип("ТабличныйДокумент") Тогда
			ПечатнаяФорма.ТабличныйДокумент.Защита = ПечатнаяФорма.Защита;
		КонецЕсли;
	КонецЦикла;
	
	ПараметрыОткрытия.Вставить("ОбъектыПечати", СтруктураРезультата.ОбъектыПечати);
	ПараметрыОткрытия.Вставить("ПараметрыВывода", СтруктураРезультата.ПараметрыВывода);
	ПараметрыОткрытия.Вставить("ПараметрыПечати", СтруктураРезультата.ПараметрыПечати); 
	
	КоллекцияПечатныхФорм	 = СтруктураРезультата.КоллекцияПечатныхФорм;
	ОфисныеДокументы		 = СтруктураРезультата.ОфисныеДокументы;
	Для Каждого ПечатнаяФорма Из КоллекцияПечатныхФорм Цикл
		ОфисныеДокументыНовыеАдреса = Новый Соответствие();
		Если ЗначениеЗаполнено(ПечатнаяФорма.ОфисныеДокументы) Тогда
			Для Каждого ОфисныйДокумент Из ПечатнаяФорма.ОфисныеДокументы Цикл
				ОфисныеДокументыНовыеАдреса.Вставить(ПоместитьВоВременноеХранилище(ОфисныеДокументы[ОфисныйДокумент.Ключ], ПараметрыОткрытия.УникальныйИдентификаторХранилища), ОфисныйДокумент.Значение);
			КонецЦикла;
			ПечатнаяФорма.ОфисныеДокументы = ОфисныеДокументыНовыеАдреса;
		КонецЕсли;
	КонецЦикла;
	
	ПараметрыОткрытия.Вставить("КоллекцияПечатныхФорм", КоллекцияПечатныхФорм);

	Если Результат.Сообщения.Количество() <> 0 Тогда
		ПараметрыОткрытия.Вставить("Сообщения", Результат.Сообщения);
	Иначе
		ПараметрыОткрытия.Вставить("Сообщения", СтруктураРезультата.Сообщения);
	КонецЕсли;
	
	ВладелецФормы = ПараметрыОткрытия.ВладелецФормы;
	ПараметрыОткрытия.Удалить("ВладелецФормы");
	
	ОткрытьФорму("ОбщаяФорма.ПечатьДокументов",
		ПараметрыОткрытия, ВладелецФормы, Строка(Новый УникальныйИдентификатор));
	
	ОбновитьКоманды(ВладелецФормы, СтруктураРезультата.ПараметрыПечати);
	
КонецПроцедуры

Функция ПараметрыОжидания(ВладелецФормы) Экспорт
	
	ПараметрыОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ВладелецФормы);
	ПараметрыОжидания.ТекстСообщения = НСтр("ru = 'Подготовка печатных форм.'");
	ПараметрыОжидания.ОповещениеПользователя.Показать = Ложь;
	ПараметрыОжидания.ВыводитьОкноОжидания = Истина;
	ПараметрыОжидания.ВыводитьСообщения = Ложь;
	Возврат ПараметрыОжидания;

КонецФункции

// Синхронный аналог ОбщегоНазначенияКлиент.СоздатьВременныйКаталог для обратной совместимости.
//
Функция СоздатьВременныйКаталог(Знач Расширение = "") Экспорт 
	
	ИмяКаталога = КаталогВременныхФайлов() + "v8_" + Строка(Новый УникальныйИдентификатор);// АПК:495 для обратной совместимости
	Если Не ПустаяСтрока(Расширение) Тогда 
		ИмяКаталога = ИмяКаталога + "." + Расширение;
	КонецЕсли;
	СоздатьКаталог(ИмяКаталога);
	Возврат ИмяКаталога;
	
КонецФункции

Процедура ПослеВыбораКомандыПоУмолчанию(Результат, ПараметрыВыполнения) Экспорт
	
	Если Результат <> Неопределено Тогда
		ПараметрыКоманды = Новый Структура("ОписаниеКоманды", ПараметрыВыполнения.ОписанияКоманд[Результат.Значение]);
		ПараметрыВыполнения = ПараметрыВыполнения.ПараметрыВыполнения;
		
		ЗаполнитьЗначенияСвойств(ПараметрыВыполнения, ПараметрыКоманды);
		ВыполнитьПодключаемуюКомандуПечатиЗавершение(Истина, ПараметрыВыполнения);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПродолжитьВыполнениеОбработчикКоманды(Результат, ПараметрыВыполнения) Экспорт
	ПараметрыВыполнения.ОписаниеКоманды = Результат;
	ВыполнитьПодключаемуюКомандуПечатиЗавершение(Истина, ПараметрыВыполнения);
КонецПроцедуры

Процедура ОбновитьКоманды(Форма, ОписаниеКоманды)
	
	Если ТипЗнч(ОписаниеКоманды) = Тип("Структура") Тогда
		ТребуетсяОбновление = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(ОписаниеКоманды, "ЗаменитьОсновнуюПечатнуюФорму", Ложь)
			Или ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(ОписаниеКоманды, "КомандаПоУмолчанию", Ложь);
			
		Если ТребуетсяОбновление Тогда
			Форма.ОтключитьОбработчикОжидания("Подключаемый_ОбновитьКоманды");
			Форма.ПодключитьОбработчикОжидания("Подключаемый_ОбновитьКоманды", 0.2, Истина);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
