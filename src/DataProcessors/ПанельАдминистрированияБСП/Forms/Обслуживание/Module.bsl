///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем ОбновитьИнтерфейс;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.РегламентныеЗадания") Тогда
		Элементы.ГруппаБлокировкаРаботыСВнешнимиРесурсами.Видимость = РегламентныеЗаданияСервер.РаботаСВнешнимиРесурсамиЗаблокирована();

		Элементы.ГруппаОбработкаРегламентныеИФоновыеЗадания.Видимость = Пользователи.ЭтоПолноправныйПользователь( ,
			Истина);
	Иначе
		Элементы.ГруппаОбработкаРегламентныеИФоновыеЗадания.Видимость = Ложь;
		Элементы.ГруппаБлокировкаРаботыСВнешнимиРесурсами.Видимость = Ложь;
	КонецЕсли;

	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеИтогамиИАгрегатами") Тогда
		Элементы.ГруппаОбработкаУправлениеИтогамиИАгрегатамиОткрыть.Видимость = Пользователи.ЭтоПолноправныйПользователь()
			И Не ОбщегоНазначения.РазделениеВключено();
	Иначе
		Элементы.ГруппаОбработкаУправлениеИтогамиИАгрегатамиОткрыть.Видимость = Ложь;
	КонецЕсли;

	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.РезервноеКопированиеИБ") Тогда
		Элементы.СтраницаНаЛокальномКомпьютере.Видимость =
			Пользователи.ЭтоПолноправныйПользователь( , Истина)
			И Не ОбщегоНазначения.РазделениеВключено()
			И Не ОбщегоНазначения.КлиентПодключенЧерезВебСервер()
			И ОбщегоНазначения.ЭтоWindowsКлиент();

		ОбновитьНастройкиРезервногоКопирования();
	Иначе
		Элементы.СтраницаНаЛокальномКомпьютере.Видимость = Ложь;
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.ОблачныйАрхив20") Тогда
		МодульОблачныйАрхив20 = ОбщегоНазначения.ОбщийМодуль("ОблачныйАрхив20");
		МодульОблачныйАрхив20.Обслуживание_ПриСозданииНаСервере(ЭтотОбъект);
	Иначе
		Элементы.СтраницаОблачныйАрхив.Видимость = Ложь;
	КонецЕсли;

	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОценкаПроизводительности") Тогда
		Элементы.ГруппаОценкаПроизводительности.Видимость = Пользователи.ЭтоПолноправныйПользователь( , Истина);
	Иначе
		Элементы.ГруппаОценкаПроизводительности.Видимость = Ложь;
	КонецЕсли;

	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ГрупповоеИзменениеОбъектов") Тогда
		Элементы.ГруппаОбработкаГрупповоеИзменениеОбъектов.Видимость = Пользователи.ЭтоПолноправныйПользователь();
	Иначе
		Элементы.ГруппаОбработкаГрупповоеИзменениеОбъектов.Видимость = Ложь;
	КонецЕсли;

	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ЗавершениеРаботыПользователей") Тогда
		МодульСоединенияИБ = ОбщегоНазначения.ОбщийМодуль("СоединенияИБ");
		Элементы.ОбработкаБлокировкаСоединенийСИнформационнойБазойОткрыть.Видимость = МодульСоединенияИБ.ПодсистемаИспользуется();
	КонецЕсли;
	
	Если Не ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ПоискИУдалениеДублей") Тогда
		Элементы.ГруппаПоискИУдалениеДублей.Видимость = Ложь;
	КонецЕсли;

	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ДополнительныеОтчетыИОбработки") Тогда
		Элементы.ГруппаДополнительныеОтчетыИОбработки.Видимость = НаборКонстант.ИспользоватьДополнительныеОтчетыИОбработки;
	Иначе
		Элементы.ГруппаДополнительныеОтчетыИОбработки.Видимость = Ложь;
	КонецЕсли;

	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОбновлениеКонфигурации") Тогда
		Элементы.ГруппаУстановленныеИсправления.Видимость = Пользователи.ЭтоПолноправныйПользователь();
	Иначе
		Элементы.ГруппаУстановкаОбновлений.Видимость = Ложь;
		Элементы.ГруппаУстановленныеИсправления.Видимость = Ложь;
	КонецЕсли;

	Если ОбщегоНазначения.ИнформационнаяБазаФайловая() Или ОбщегоНазначения.РазделениеВключено() Тогда
		Элементы.ГруппаНастройкаПриоритетаОбновления.Видимость = Ложь;
	Иначе
		КоличествоПотоковОбновления = ОбновлениеИнформационнойБазы.КоличествоПотоковОбновления();
		ПриоритетОбработкиДанных    = ОбновлениеИнформационнойБазы.ПриоритетОтложеннойОбработки();
		Элементы.КоличествоПотоковОбновления.Видимость = ОбновлениеИнформационнойБазы.РазрешеноМногопоточноеОбновление();
		НастроитьИспользованиеКоличестваПотоковОбновления(ПриоритетОбработкиДанных);
	КонецЕсли;
	
	Если Не Пользователи.ЭтоПолноправныйПользователь(, Истина) Тогда
		Элементы.ОчисткаУстаревшихДанных.Видимость = Ложь;
	КонецЕсли;
	
	// Обновление состояния элементов.
	УстановитьДоступность();

	НастройкиПрограммыПереопределяемый.ОбслуживаниеПриСозданииНаСервере(ЭтотОбъект);

КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)

	Если ИмяСобытия = "ЗакрытаФормаНастройкиРезервногоКопирования" И ОбщегоНазначенияКлиент.ПодсистемаСуществует(
		"СтандартныеПодсистемы.РезервноеКопированиеИБ") Тогда
		ОбновитьНастройкиРезервногоКопирования();
	ИначеЕсли ИмяСобытия = "РазрешенаРаботаСВнешнимиРесурсами" Тогда
		Элементы.ГруппаБлокировкаРаботыСВнешнимиРесурсами.Видимость = Ложь;
		СтандартныеПодсистемыКлиент.УстановитьРасширенныйЗаголовокПриложения();
	ИначеЕсли ИмяСобытия = "ЗапрещенаРаботаСВнешнимиРесурсами" Тогда
		Элементы.ГруппаБлокировкаРаботыСВнешнимиРесурсами.Видимость = Истина;
		СтандартныеПодсистемыКлиент.УстановитьРасширенныйЗаголовокПриложения();
	КонецЕсли;
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.ОблачныйАрхив20") Тогда
		МодульОблачныйАрхив20Клиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ОблачныйАрхив20Клиент");
		МодульОблачныйАрхив20Клиент.Обслуживание_ОбработкаОповещения(ЭтотОбъект, ИмяСобытия, Параметр, Источник);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	Если ЗавершениеРаботы Тогда
		Возврат;
	КонецЕсли;
	ОбновитьИнтерфейсПрограммы();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

#Область ИнтернетПоддержкаПользователей_ОблачныйАрхив20

&НаКлиенте
Процедура ХранениеРезервныхКопийПриИзменении(Элемент)
	
	// В зависимости от выбранного варианта хранения, вывести правильную страницу.
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.ОблачныйАрхив20") Тогда
		МодульОблачныйАрхив20Клиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ОблачныйАрхив20Клиент");
		МодульОблачныйАрхив20Клиент.Обслуживание_ХранениеРезервныхКопийПриИзменении(ЭтотОбъект, ХранениеРезервныхКопий);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ХранениеРезервныхКопийОчистка(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
КонецПроцедуры

&НаКлиенте
Процедура ОблачныйАрхивСозданиеРезервнойКопииНажатие(Элемент)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.ОблачныйАрхив20") Тогда
		МодульОблачныйАрхив20Клиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ОблачныйАрхив20Клиент");
		МодульОблачныйАрхив20Клиент.ОткрытьФормуРезервногоКопирования();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОблачныйАрхивОткрытьАрхивныеКопииНажатие(Элемент)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.ОблачныйАрхив20") Тогда
		МодульОблачныйАрхив20Клиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ОблачныйАрхив20Клиент");
		МодульОблачныйАрхив20Клиент.ОткрытьСписокРезервныхКопий();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПояснениеОблачныйАрхивРаботаетОбработкаНавигационнойСсылки(
	Элемент,
	НавигационнаяСсылкаФорматированнойСтроки,
	СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.ОблачныйАрхив20") Тогда
		МодульОблачныйАрхив20Клиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ОблачныйАрхив20Клиент");
		Если НавигационнаяСсылкаФорматированнойСтроки = "setting" Тогда
			МодульОблачныйАрхив20Клиент.ОткрытьФормуНастройкиОблачногоАрхива();
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

&НаКлиенте
Процедура ВыполнятьЗамерыПроизводительностиПриИзменении(Элемент)
	Подключаемый_ПриИзмененииРеквизита(Элемент);
КонецПроцедуры

&НаКлиенте
Процедура ДетализироватьОбновлениеИБВЖурналеРегистрацииПриИзменении(Элемент)
	Подключаемый_ПриИзмененииРеквизита(Элемент);
КонецПроцедуры

&НаКлиенте
Процедура ПриоритетОтложеннойОбработкиДанныхПриИзменении(Элемент)
	УстановитьПриоритетОтложеннойОбработки(Элемент.Имя);
КонецПроцедуры

&НаКлиенте
Процедура КоличествоПотоковОбновленияИнформационнойБазыПриИзменении(Элемент)
	УстановитьКоличествоПотоковОбновления();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

#Область ИнтернетПоддержкаПользователей_ОблачныйАрхив20

&НаКлиенте
Процедура ОблачныйАрхивНастройкаРезервногоКопирования(Команда)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.ОблачныйАрхив20") Тогда
		МодульОблачныйАрхив20Клиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ОблачныйАрхив20Клиент");
		МодульОблачныйАрхив20Клиент.ОткрытьФормуНастройкиОблачногоАрхива();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

&НаКлиенте
Процедура РазблокироватьРаботуСВнешнимиРесурсами(Команда)
	РазблокироватьРаботуСВнешнимиРесурсамиНаСервере();
	СтандартныеПодсистемыКлиент.УстановитьРасширенныйЗаголовокПриложения();
	Оповестить("РазрешенаРаботаСВнешнимиРесурсами");
	ОбновитьИнтерфейс();
КонецПроцедуры

&НаКлиенте
Процедура ОтложеннаяОбработкаДанных(Команда)
	ПараметрыФормы = Новый Структура("ОткрытиеИзПанелиАдминистрирования", Истина);
	ОткрытьФорму("Обработка.РезультатыОбновленияПрограммы.Форма.РезультатыОбновленияПрограммы", ПараметрыФормы);
КонецПроцедуры

&НаКлиенте
Процедура ОчисткаУстаревшихДанных(Команда)
	
	ОткрытьФорму("Обработка.РезультатыОбновленияПрограммы.Форма.ОчисткаУстаревшихДанных");
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область Клиент

&НаКлиенте
Процедура Подключаемый_ПриИзмененииРеквизита(Элемент, НеобходимоОбновлятьИнтерфейс = Истина)

	ИмяКонстанты = ПриИзмененииРеквизитаСервер(Элемент.Имя);
	ОбновитьПовторноИспользуемыеЗначения();

	Если НеобходимоОбновлятьИнтерфейс Тогда
		ОбновитьИнтерфейс = Истина;
		ПодключитьОбработчикОжидания("ОбновитьИнтерфейсПрограммы", 2, Истина);
	КонецЕсли;

	Если ИмяКонстанты <> "" Тогда
		Оповестить("Запись_НаборКонстант", Новый Структура, ИмяКонстанты);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ОбновитьИнтерфейсПрограммы()

	Если ОбновитьИнтерфейс = Истина Тогда
		ОбновитьИнтерфейс = Ложь;
		ОбщегоНазначенияКлиент.ОбновитьИнтерфейсПрограммы();
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область ВызовСервера

&НаСервере
Функция ПриИзмененииРеквизитаСервер(ИмяЭлемента)

	РеквизитПутьКДанным = Элементы[ИмяЭлемента].ПутьКДанным;
	ИмяКонстанты = СохранитьЗначениеРеквизита(РеквизитПутьКДанным);
	УстановитьДоступность(РеквизитПутьКДанным);
	ОбновитьПовторноИспользуемыеЗначения();
	Возврат ИмяКонстанты;

КонецФункции

#КонецОбласти

#Область Сервер

&НаСервере
Процедура УстановитьПриоритетОтложеннойОбработки(ИмяЭлемента)
	ОбновлениеИнформационнойБазы.УстановитьПриоритетОтложеннойОбработки(ПриоритетОбработкиДанных);
	НастроитьИспользованиеКоличестваПотоковОбновления(ПриоритетОбработкиДанных);
КонецПроцедуры

&НаСервере
Процедура НастроитьИспользованиеКоличестваПотоковОбновления(Приоритет)
	Элементы.КоличествоПотоковОбновления.Доступность = (Приоритет = "ОбработкаДанных");
КонецПроцедуры

&НаСервере
Процедура УстановитьКоличествоПотоковОбновления()
	ОбновлениеИнформационнойБазы.УстановитьКоличествоПотоковОбновления(КоличествоПотоковОбновления);
КонецПроцедуры

&НаСервере
Функция СохранитьЗначениеРеквизита(РеквизитПутьКДанным)

	ЧастиИмени = СтрРазделить(РеквизитПутьКДанным, ".");
	Если ЧастиИмени.Количество() <> 2 Тогда
		Возврат "";
	КонецЕсли;

	ИмяКонстанты = ЧастиИмени[1];
	КонстантаМенеджер = Константы[ИмяКонстанты];
	КонстантаЗначение = НаборКонстант[ИмяКонстанты];

	Если КонстантаМенеджер.Получить() <> КонстантаЗначение Тогда
		КонстантаМенеджер.Установить(КонстантаЗначение);
	КонецЕсли;

	Возврат ИмяКонстанты;

КонецФункции

&НаСервере
Процедура УстановитьДоступность(РеквизитПутьКДанным = "")

	Если Не Пользователи.ЭтоПолноправныйПользователь( , Истина) Тогда
		Возврат;
	КонецЕсли;

	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОценкаПроизводительности") И (РеквизитПутьКДанным
		= "НаборКонстант.ВыполнятьЗамерыПроизводительности" Или РеквизитПутьКДанным = "") Тогда
		ЭлементОбработкаОценкаПроизводительностиИмпортЗамеровПроизводительности = Элементы.Найти(
			"ОбработкаОценкаПроизводительностиИмпортЗамеровПроизводительности");
		ЭлементОбработкаОценкаПроизводительностиЭкспортДанных = Элементы.Найти(
			"ОбработкаОценкаПроизводительностиЭкспортДанных");
		ЭлементСправочникПрофилиКлючевыхОперацийОткрытьСписок = Элементы.Найти(
			"СправочникПрофилиКлючевыхОперацийОткрытьСписок");
		ЭлементОбработкаНастройкиОценкиПроизводительности = Элементы.Найти("ОбработкаНастройкиОценкиПроизводительности");
		Если (ЭлементОбработкаНастройкиОценкиПроизводительности <> Неопределено
			И ЭлементОбработкаОценкаПроизводительностиЭкспортДанных <> Неопределено
			И ЭлементСправочникПрофилиКлючевыхОперацийОткрытьСписок <> Неопределено
			И ЭлементОбработкаОценкаПроизводительностиИмпортЗамеровПроизводительности <> Неопределено
			И НаборКонстант.Свойство("ВыполнятьЗамерыПроизводительности")) Тогда
			ЭлементОбработкаНастройкиОценкиПроизводительности.Доступность = НаборКонстант.ВыполнятьЗамерыПроизводительности;
			ЭлементОбработкаОценкаПроизводительностиЭкспортДанных.Доступность = НаборКонстант.ВыполнятьЗамерыПроизводительности;
			ЭлементСправочникПрофилиКлючевыхОперацийОткрытьСписок.Доступность = НаборКонстант.ВыполнятьЗамерыПроизводительности;
			ЭлементОбработкаОценкаПроизводительностиИмпортЗамеровПроизводительности.Доступность = НаборКонстант.ВыполнятьЗамерыПроизводительности;
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура ОбновитьНастройкиРезервногоКопирования()

	Если Не ОбщегоНазначения.РазделениеВключено() И Пользователи.ЭтоПолноправныйПользователь( , Истина) Тогда

		МодульРезервноеКопированиеИБСервер = ОбщегоНазначения.ОбщийМодуль("РезервноеКопированиеИБСервер");
		Элементы.НастройкаРезервногоКопированияИБ.РасширеннаяПодсказка.Заголовок = МодульРезервноеКопированиеИБСервер.ТекущаяНастройкаРезервногоКопирования();
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура РазблокироватьРаботуСВнешнимиРесурсамиНаСервере()
	Элементы.ГруппаБлокировкаРаботыСВнешнимиРесурсами.Видимость = Ложь;
	МодульРегламентныеЗаданияСервер = ОбщегоНазначения.ОбщийМодуль("РегламентныеЗаданияСервер");
	МодульРегламентныеЗаданияСервер.РазблокироватьРаботуСВнешнимиРесурсами();
КонецПроцедуры

#КонецОбласти

#КонецОбласти