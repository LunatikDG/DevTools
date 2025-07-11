///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

// Возвращает описание команды по имени элемента формы.
Функция ОписаниеКоманды(ИмяКомандыВФорме, АдресНастроек) Экспорт
	Возврат ПодключаемыеКоманды.ОписаниеКоманды(ИмяКомандыВФорме, АдресНастроек);
КонецФункции

Функция ПометкиОсновныхКоманд(Знач Ссылка, Знач КомандыСПометкой) Экспорт
	
	Результат = Новый Структура;
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Печать") Тогда
		МодульУправлениеПечатью = ОбщегоНазначения.ОбщийМодуль("УправлениеПечатью");
		МодульУправлениеПечатью.ПриОбновленииПометкиОсновныхКоманд(Ссылка, КомандыСПометкой, Результат);
	КонецЕсли;
	Возврат Результат;
	
КонецФункции

// Проверяет статус проведения переданных документов и возвращает те из них, которые не проведены.
//
// Параметры:
//  Документы - Массив из ДокументСсылка - документы, статус проведения которых необходимо проверить.
//
// Возвращаемое значение:
//  Структура:
//    * НепроведенныеДокументы - Массив из ДокументСсылка
//    * ЕстьПравоПроведения - Булево
//
Функция СведенияОПроведенииДокументов(Знач Документы) Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("НепроведенныеДокументы", 
		ОбщегоНазначения.ПроверитьПроведенностьДокументов(Документы));
	Результат.Вставить("ЕстьПравоПроведения", 
		СтандартныеПодсистемыСервер.ДоступноПравоПроведения(Результат.НепроведенныеДокументы));
	Возврат Результат;
	
КонецФункции

#КонецОбласти
