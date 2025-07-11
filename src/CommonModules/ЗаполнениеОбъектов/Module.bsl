///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// Список объектов, в которых используются команды заполнения.
//
// Возвращаемое значение:
//   Массив из ОбъектМетаданных - объекты метаданных с командами заполнения.
//
Функция ОбъектыСКомандамиЗаполнения() Экспорт
	Массив = Новый Массив;
	ЗаполнениеОбъектовПереопределяемый.ПриОпределенииОбъектовСКомандамиЗаполнения(Массив);
	Возврат Массив;
КонецФункции

#Область ОбработчикиСобытийПодсистемКонфигурации

// См. ПодключаемыеКомандыПереопределяемый.ПриОпределенииСоставаНастроекПодключаемыхОбъектов
Процедура ПриОпределенииСоставаНастроекПодключаемыхОбъектов(НастройкиПрограммногоИнтерфейса) Экспорт
	Настройка = НастройкиПрограммногоИнтерфейса.Добавить();
	Настройка.Ключ          = "ДобавитьКомандыЗаполнения";
	Настройка.ОписаниеТипов = Новый ОписаниеТипов("Булево");
КонецПроцедуры

// См. ПодключаемыеКомандыПереопределяемый.ПриОпределенииВидовПодключаемыхКоманд
Процедура ПриОпределенииВидовПодключаемыхКоманд(ВидыПодключаемыхКоманд) Экспорт
	Вид = ВидыПодключаемыхКоманд.Добавить();
	Вид.Имя         = "ЗаполнениеОбъектов";
	Вид.ИмяПодменю  = "ПодменюЗаполнить";
	Вид.Заголовок   = НСтр("ru = 'Заполнить'");
	Вид.Порядок     = 60;
	Вид.Картинка    = БиблиотекаКартинок.ЗаполнитьФорму;
	Вид.Отображение = ОтображениеКнопки.КартинкаИТекст;
КонецПроцедуры

// См. ПодключаемыеКомандыПереопределяемый.ПриОпределенииКомандПодключенныхКОбъекту
Процедура ПриОпределенииКомандПодключенныхКОбъекту(НастройкиФормы, Источники, ПодключенныеОтчетыИОбработки, Команды) Экспорт
	КомандыЗаполнения = Команды.СкопироватьКолонки();
	КомандыЗаполнения.Колонки.Добавить("Обработана", Новый ОписаниеТипов("Булево"));
	КомандыЗаполнения.Индексы.Добавить("Обработана");
	
	СтандартнаяОбработка = Источники.Строки.Количество() > 0;
	ЗаполнениеОбъектовПереопределяемый.ПередДобавлениемКомандЗаполнения(КомандыЗаполнения, НастройкиФормы, СтандартнаяОбработка);
	КомандыЗаполнения.ЗаполнитьЗначения(Истина, "Обработана");
	
	ДопустимыеТипы = Новый Массив; // Типы источников, которые пользователь может изменять (см. ниже проверку права "Изменение").
	Если СтандартнаяОбработка Тогда
		ОбъектыСКомандамиЗаполнения = ОбъектыСКомандамиЗаполнения();
		Для Каждого Источник Из Источники.Строки Цикл
			Для Каждого ДокументРегистратор Из Источник.Строки Цикл
				Если Не ДокументРегистратор.ЭтоЖурналДокументов
					И Не ПравоДоступа("Изменение", ДокументРегистратор.Метаданные) Тогда
					Продолжить;
				КонецЕсли;
				ПодключаемыеКоманды.ДополнитьМассивТипов(ДопустимыеТипы, ДокументРегистратор.ТипСсылкиДанных);
				Если ОбъектыСКомандамиЗаполнения.Найти(ДокументРегистратор.Метаданные) <> Неопределено Тогда
					ПриДобавленииКомандЗаполнения(КомандыЗаполнения, ДокументРегистратор, НастройкиФормы);
				КонецЕсли;
			КонецЦикла;
			Если Не Источник.ЭтоЖурналДокументов
				И Не ПравоДоступа("Изменение", Источник.Метаданные) Тогда
				Продолжить;
			КонецЕсли;
			ПодключаемыеКоманды.ДополнитьМассивТипов(ДопустимыеТипы, Источник.ТипСсылкиДанных);
			Если ОбъектыСКомандамиЗаполнения.Найти(Источник.Метаданные) <> Неопределено Тогда
				ПриДобавленииКомандЗаполнения(КомандыЗаполнения, Источник, НастройкиФормы);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	Если ДопустимыеТипы.Количество() = 0 Тогда
		Возврат; // Все закрыто и команд расширений с допустимыми типами тоже не будет.
	КонецЕсли;
	
	Найденные = ПодключенныеОтчетыИОбработки.НайтиСтроки(Новый Структура("ДобавитьКомандыЗаполнения", Истина));
	Для Каждого ПодключенныйОбъект Из Найденные Цикл
		ПриДобавленииКомандЗаполнения(КомандыЗаполнения, ПодключенныйОбъект, НастройкиФормы, ДопустимыеТипы);
	КонецЦикла;
	
	Для Каждого КомандаЗаполнения Из КомандыЗаполнения Цикл
		Команда = Команды.Добавить();
		ЗаполнитьЗначенияСвойств(Команда, КомандаЗаполнения);
		Команда.Вид = "ЗаполнениеОбъектов";
		Если Команда.Порядок = 0 Тогда
			Команда.Порядок = 50;
		КонецЕсли;
		Если Команда.РежимЗаписи = "" Тогда
			Команда.РежимЗаписи = "Записывать";
		КонецЕсли;
		Если КомандаЗаполнения.ИзменяетВыбранныеОбъекты = Неопределено Тогда
			Команда.ИзменяетВыбранныеОбъекты = Истина;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

////////////////////////////////////////////////////////////////////////////////
// Вспомогательные для служебного программного интерфейса

Процедура ПриДобавленииКомандЗаполнения(Команды, СведенияОбОбъекте, НастройкиФормы, ДопустимыеТипы = Неопределено)
	СведенияОбОбъекте.Менеджер.ДобавитьКомандыЗаполнения(Команды, НастройкиФормы);
	ДобавленныеКоманды = Команды.НайтиСтроки(Новый Структура("Обработана", Ложь));
	Для Каждого Команда Из ДобавленныеКоманды Цикл
		Если Не ЗначениеЗаполнено(Команда.Менеджер) Тогда
			Команда.Менеджер = СведенияОбОбъекте.ПолноеИмя;
		КонецЕсли;
		Если Не ЗначениеЗаполнено(Команда.ТипПараметра) Тогда
			Команда.ТипПараметра = СведенияОбОбъекте.ТипСсылкиДанных;
		КонецЕсли;
		Если ДопустимыеТипы <> Неопределено И Не ТипВМассиве(Команда.ТипПараметра, ДопустимыеТипы) Тогда
			Команды.Удалить(Команда);
			Продолжить;
		КонецЕсли;
		Команда.Обработана = Истина;
	КонецЦикла;
КонецПроцедуры

Функция ТипВМассиве(ТипИлиОписаниеТипов, МассивТипов)
	Если ТипЗнч(ТипИлиОписаниеТипов) = Тип("ОписаниеТипов") Тогда
		Для Каждого Тип Из ТипИлиОписаниеТипов.Типы() Цикл
			Если МассивТипов.Найти(Тип) <> Неопределено Тогда
				Возврат Истина;
			КонецЕсли;
		КонецЦикла;
		Возврат Ложь
	Иначе
		Возврат МассивТипов.Найти(ТипИлиОписаниеТипов) <> Неопределено;
	КонецЕсли;
КонецФункции

#КонецОбласти