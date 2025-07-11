///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

// Для внутреннего использования.
//
Процедура ВыполнитьАвтоматическоеСопоставлениеДанных(Параметры, АдресВременногоХранилища) Экспорт
	
	Результат = РезультатАвтоматическогоСопоставленияДанных(
		Параметры.УзелИнформационнойБазы,
		Параметры.ИмяФайлаСообщенияОбмена,
		Параметры.ИмяВременногоКаталогаСообщенийОбмена,
		Параметры.ПроверятьРасхождениеВерсий);
	
	ПоместитьВоВременноеХранилище(Результат, АдресВременногоХранилища);
		
КонецПроцедуры

// Для внутреннего использования.
// Выполняет загрузку сообщения обмена из внешнего источника
//  (ftp, e-mail, сетевой каталог) во временный каталог пользователя операционной системы.
//
Процедура ПолучитьСообщениеОбменаВоВременныйКаталог(Параметры, АдресВременногоХранилища) Экспорт
	
	Отказ = Ложь;
	УстановитьПривилегированныйРежим(Истина);
	
	СтруктураДанных = Новый Структура;
	СтруктураДанных.Вставить("ИмяВременногоКаталогаСообщенийОбмена", "");
	СтруктураДанных.Вставить("ИдентификаторФайлаПакетаДанных",       Неопределено);
	СтруктураДанных.Вставить("ИмяФайлаСообщенияОбмена",              "");
	
	Если Параметры.ПолученоСообщениеДляСопоставленияДанных Тогда
		
		Отбор = Новый Структура("УзелИнформационнойБазы", Параметры.УзелИнформационнойБазы);
		ОбщиеНастройки = РегистрыСведений.ОбщиеНастройкиУзловИнформационныхБаз.Получить(Отбор);
		
		ИмяВременногоФайла = "";
		Если ЗначениеЗаполнено(ОбщиеНастройки.СообщениеДляСопоставленияДанных) Тогда
	
			ПассивныйРежимФайловаяИБ = ОбщегоНазначения.ИнформационнаяБазаФайловая()
				И ТранспортСообщенийОбмена.ПараметрТранспорта(Параметры.ИдентификаторТранспорта, "ПассивныйРежим");
			
			ИмяВременногоФайла = ОбменДаннымиСервер.ПолучитьФайлИзХранилища(ОбщиеНастройки.СообщениеДляСопоставленияДанных, ПассивныйРежимФайловаяИБ);
			
			Файл = Новый Файл(ИмяВременногоФайла);
			Если Файл.Существует() И Файл.ЭтоФайл() Тогда
				// Помещаем информацию о сообщении для сопоставления обратно в хранилище,
				// на случай аварийного завершения процесса анализа данных, для возможности повторной работы с сообщением.
				ОбменДаннымиСервер.ПоместитьФайлВХранилище(ИмяВременногоФайла, ОбщиеНастройки.СообщениеДляСопоставленияДанных);
				
				ИдентификаторФайлаПакетаДанных = Файл.ПолучитьВремяИзменения();
				
				ИдентификаторКаталогаДляОбмена = "";
				ИмяВременногоКаталогаДляОбмена = ОбменДаннымиСервер.СоздатьВременныйКаталогСообщенийОбмена(ИдентификаторКаталогаДляОбмена);
				ИмяВременногоФайлаДляОбмена    = ОбщегоНазначенияКлиентСервер.ПолучитьПолноеИмяФайла(
					ИмяВременногоКаталогаДляОбмена, ОбменДаннымиСервер.УникальноеИмяФайлаСообщенияОбмена());
				
				КопироватьФайл(ИмяВременногоФайла, ИмяВременногоФайлаДляОбмена);
				
				СтруктураДанных.ИмяВременногоКаталогаСообщенийОбмена = ИмяВременногоКаталогаДляОбмена;
				СтруктураДанных.ИдентификаторФайлаПакетаДанных       = ИдентификаторФайлаПакетаДанных;
				СтруктураДанных.ИмяФайлаСообщенияОбмена              = ИмяВременногоФайлаДляОбмена;
				
				Параметры.ИдентификаторВременногоКаталогаДляОбмена   = Строка(ИдентификаторКаталогаДляОбмена);
			Иначе
				ОбменДаннымиСлужебный.ПоместитьСообщениеДляСопоставленияДанных(Параметры.УзелИнформационнойБазы, Неопределено);
			КонецЕсли;
			
		КонецЕсли;
		
		Если ПустаяСтрока(СтруктураДанных.ИмяФайлаСообщенияОбмена) Тогда
			// Файл сообщения для сопоставления не найден.
			Отказ = Истина;
			
			СообщениеОбОшибке = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Сообщение для сопоставления с идентификатором %1 не найдено по пути %2.'"),
				Строка(ОбщиеНастройки.СообщениеДляСопоставленияДанных),
				ИмяВременногоФайла);
			
			Параметры.Вставить("СообщениеОбОшибке", СообщениеОбОшибке);
		КонецЕсли;
	
	Иначе
		
		ПараметрыИнициализации = ТранспортСообщенийОбмена.ПараметрыИнициализации();
		ПараметрыИнициализации.Корреспондент = Параметры.УзелИнформационнойбазы;
		ЗаполнитьЗначенияСвойств(ПараметрыИнициализации, Параметры);
		
		Транспорт = ТранспортСообщенийОбмена.Инициализация(ПараметрыИнициализации);
		
		Если Транспорт.ПолучитьДанные() Тогда
			СтруктураДанных.ИмяФайлаСообщенияОбмена = Транспорт.СообщениеОбмена;
			СтруктураДанных.ИмяВременногоКаталогаСообщенийОбмена = Транспорт.ВременныйКаталог;
			
			Файл = Новый Файл(Транспорт.СообщениеОбмена);
			Если Файл.Существует() Тогда
				СтруктураДанных.ИдентификаторФайлаПакетаДанных = Файл.ПолучитьВремяИзменения();
			КонецЕсли;
			
		Иначе
			
			Отказ = Истина;
		
		КонецЕсли;
		
	КонецЕсли;
	
	Параметры.Отказ                                = Отказ;
	Параметры.ИмяВременногоКаталогаСообщенийОбмена = СтруктураДанных.ИмяВременногоКаталогаСообщенийОбмена;
	Параметры.ИдентификаторФайлаПакетаДанных       = СтруктураДанных.ИдентификаторФайлаПакетаДанных;
	Параметры.ИмяФайлаСообщенияОбмена              = СтруктураДанных.ИмяФайлаСообщенияОбмена;
	
	ПоместитьВоВременноеХранилище(Параметры, АдресВременногоХранилища);
	
КонецПроцедуры

// Для внутреннего использования.
//
Процедура ВыполнитьЗагрузкуДанных(Параметры, АдресВременногоХранилища) Экспорт
	
	ПараметрыОбменаДанными = ОбменДаннымиСервер.ПараметрыОбменаДаннымиЧерезФайлИлиСтроку();
	
	ПараметрыОбменаДанными.УзелИнформационнойБазы        = Параметры.УзелИнформационнойБазы;
	ПараметрыОбменаДанными.ПолноеИмяФайлаСообщенияОбмена = Параметры.ИмяФайлаСообщенияОбмена;
	ПараметрыОбменаДанными.ДействиеПриОбмене             = Перечисления.ДействияПриОбмене.ЗагрузкаДанных;
	
	ОбменДаннымиСервер.ВыполнитьОбменДаннымиДляУзлаИнформационнойБазыЧерезФайлИлиСтроку(ПараметрыОбменаДанными);
	
КонецПроцедуры

// Для внутреннего использования.
// Выполняет выгрузку данных, вызывается фоновым заданием.
// Параметры - структура с параметрами для передачи.
//
Процедура ВыполнитьВыгрузкуДанных(Параметры, АдресВременногоХранилища) Экспорт
	
	Отказ = Ложь;
	
	ПараметрыОбмена = ОбменДаннымиСервер.ПараметрыОбмена();
	ПараметрыОбмена.ВыполнятьЗагрузку            = Ложь;
	ПараметрыОбмена.ВыполнятьВыгрузку            = Истина;
	ПараметрыОбмена.ДлительнаяОперацияРазрешена  = Истина;
	ПараметрыОбмена.ИдентификаторТранспорта      = Параметры.ИдентификаторТранспорта;
	ПараметрыОбмена.ДлительнаяОперация           = Параметры.ДлительнаяОперация;
	ПараметрыОбмена.ИдентификаторОперации        = Параметры.ИдентификаторОперации;
	ПараметрыОбмена.ИдентификаторФайла           = Параметры.ИдентификаторФайла;
	ПараметрыОбмена.ДанныеАутентификации         = Параметры.ДанныеАутентификации;
	
	ОбменДаннымиСервер.ВыполнитьОбменДаннымиДляУзлаИнформационнойБазы(Параметры.УзелИнформационнойБазы, ПараметрыОбмена, Отказ);
	
	Параметры.ДлительнаяОперация      = ПараметрыОбмена.ДлительнаяОперация;
	Параметры.ИдентификаторОперации   = ПараметрыОбмена.ИдентификаторОперации;
	Параметры.ИдентификаторФайла      = ПараметрыОбмена.ИдентификаторФайла;
	Параметры.ДанныеАутентификации    = ПараметрыОбмена.ДанныеАутентификации;
	
	Параметры.Отказ                   = Отказ;
	
	ПоместитьВоВременноеХранилище(Параметры, АдресВременногоХранилища);
	
КонецПроцедуры

// Для внутреннего использования.
// 
// Параметры:
//  ИнформацияСтатистики - ТаблицаЗначений 
// 
// Возвращаемое значение:
//  Булево - все данные сопоставлены
//
Функция ВсеДанныеСопоставлены(ИнформацияСтатистики) Экспорт
	
	Возврат (ИнформацияСтатистики.НайтиСтроки(Новый Структура("ИндексКартинки", 1)).Количество() = 0);
	
КонецФункции

// Для внутреннего использования.
// 
// Параметры:
//  ИнформацияСтатистики - ТаблицаЗначений 
// 
// Возвращаемое значение:
//  Булево - есть не сопоставленная НСИ
//
Функция ЕстьНеСопоставленнаяНСИ(ИнформацияСтатистики) Экспорт
	Возврат (ИнформацияСтатистики.НайтиСтроки(Новый Структура("ИндексКартинки, ЭтоНСИ", 1, Истина)).Количество() > 0);
КонецФункции

#Область РегистрацияДанных

Процедура ПриНачалеРегистрацииДанных(НастройкиРегистрации, ПараметрыОбработчика, ПродолжитьОжидание = Истина) Экспорт
	
	КлючФоновогоЗадания = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Регистрация данных для выгрузки (%1)'"),
		НастройкиРегистрации.УзелОбмена);

	Если ОбменДаннымиСервер.ЕстьАктивныеФоновыеЗадания(КлючФоновогоЗадания) Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Регистрация данных для начальной выгрузки для ""%1"" уже выполняется.'"),
			НастройкиРегистрации.УзелОбмена);
	КонецЕсли;
		
	ПараметрыПроцедуры = Новый Структура;
	ПараметрыПроцедуры.Вставить("НастройкиРегистрации", НастройкиРегистрации);
	
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияВФоне(Новый УникальныйИдентификатор);
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Регистрация данных для выгрузки (%1).'"),
		НастройкиРегистрации.УзелОбмена);
	ПараметрыВыполнения.КлючФоновогоЗадания = КлючФоновогоЗадания;
	ПараметрыВыполнения.ЗапуститьНеВФоне    = Ложь;
	
	ФоновоеЗадание = ДлительныеОперации.ВыполнитьВФоне(
		"Обработки.ПомощникИнтерактивногоОбменаДанными.ЗарегистрироватьДанныеДляВыгрузки",
		ПараметрыПроцедуры,
		ПараметрыВыполнения);
		
	ПриНачалеДлительнойОперации(ФоновоеЗадание, ПараметрыОбработчика, ПродолжитьОжидание);
	
КонецПроцедуры

Процедура ПриОжиданииРегистрацииДанных(ПараметрыОбработчика, ПродолжитьОжидание = Истина) Экспорт
	
	ПриОжиданииДлительнойОперации(ПараметрыОбработчика, ПродолжитьОжидание);
	
КонецПроцедуры

Процедура ПриЗавершенииРегистрацииДанных(ПараметрыОбработчика, СтатусЗавершения) Экспорт
	
	ПриЗавершенииДлительнойОперации(ПараметрыОбработчика, СтатусЗавершения);
	
КонецПроцедуры

#КонецОбласти

#Область ВыгрузкаДанныхДляСопоставления

// Для внутреннего использования.
//
Процедура ПриНачалеВыгрузкиДанныхДляСопоставления(НастройкиВыгрузки, ПараметрыОбработчика, ПродолжитьОжидание = Истина) Экспорт
	
	КлючФоновогоЗадания = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Выгрузка данных для сопоставления (%1)'"),
		НастройкиВыгрузки.УзелОбмена);

	АктивныеФоновыеЗадания = Неопределено;
	Если ОбменДаннымиСервер.ЕстьАктивныеФоновыеЗадания(КлючФоновогоЗадания, АктивныеФоновыеЗадания) Тогда
		ЗавершитьФоновыеЗадания(КлючФоновогоЗадания, АктивныеФоновыеЗадания);
	КонецЕсли;
	
	Если ОбменДаннымиСервер.ЕстьАктивныеФоновыеЗадания(КлючФоновогоЗадания) Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Выгрузка данных для сопоставления для ""%1"" уже выполняется.'"),
			НастройкиВыгрузки.УзелОбмена);
	КонецЕсли;
		
	ПараметрыПроцедуры = Новый Структура;
	ПараметрыПроцедуры.Вставить("НастройкиВыгрузки", НастройкиВыгрузки);
	
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияВФоне(Новый УникальныйИдентификатор);
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Выгрузка данных для сопоставления (%1).'"),
		НастройкиВыгрузки.УзелОбмена);
	ПараметрыВыполнения.КлючФоновогоЗадания = КлючФоновогоЗадания;
	ПараметрыВыполнения.ЗапуститьНеВФоне    = Ложь;
	
	ФоновоеЗадание = ДлительныеОперации.ВыполнитьВФоне(
		"Обработки.ПомощникИнтерактивногоОбменаДанными.ВыгрузитьДанныеДляСопоставления",
		ПараметрыПроцедуры,
		ПараметрыВыполнения);
		
	ПриНачалеДлительнойОперации(ФоновоеЗадание, ПараметрыОбработчика, ПродолжитьОжидание);
	
КонецПроцедуры

// Для внутреннего использования.
//
Процедура ПриЗавершенииВыгрузкиДанныхДляСопоставления(ПараметрыОбработчика, СтатусЗавершения) Экспорт
	
	ПриЗавершенииДлительнойОперации(ПараметрыОбработчика, СтатусЗавершения);
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ЗарегистрироватьДанныеДляВыгрузки(Параметры, АдресРезультата) Экспорт
	
	НастройкиРегистрации = Неопределено;
	Параметры.Свойство("НастройкиРегистрации", НастройкиРегистрации);
	
	Результат = Новый Структура;
	Результат.Вставить("ДанныеЗарегистрированы", Истина);
	Результат.Вставить("СообщениеОбОшибке",      "");
	
	СтруктураДополнение = НастройкиРегистрации.ДополнениеВыгрузки;
	
	ДополнениеВыгрузки = Обработки.ИнтерактивноеИзменениеВыгрузки.Создать();
	ЗаполнитьЗначенияСвойств(ДополнениеВыгрузки, СтруктураДополнение, , "ДополнительнаяРегистрация, ДополнительнаяРегистрацияСценарияУзла");
	
	ДополнениеВыгрузки.КомпоновщикОтбораВсехДокументов.ЗагрузитьНастройки(СтруктураДополнение.КомпоновщикОтбораВсехДокументовНастройки);
		
	ОбменДаннымиСервер.ЗаполнитьТаблицуЗначений(ДополнениеВыгрузки.ДополнительнаяРегистрация, СтруктураДополнение.ДополнительнаяРегистрация);
	ОбменДаннымиСервер.ЗаполнитьТаблицуЗначений(ДополнениеВыгрузки.ДополнительнаяРегистрацияСценарияУзла, СтруктураДополнение.ДополнительнаяРегистрацияСценарияУзла);
	
	Если Не СтруктураДополнение.КомпоновщикВсехДокументов = Неопределено Тогда
		ДополнениеВыгрузки.АдресКомпоновщикаВсехДокументов = ПоместитьВоВременноеХранилище(СтруктураДополнение.КомпоновщикВсехДокументов);
	КонецЕсли;
	
	// Сохраняем настройки дополнения выгрузки.
	ОбменДаннымиСервер.ИнтерактивноеИзменениеВыгрузкиСохранитьНастройки(ДополнениеВыгрузки, 
		ОбменДаннымиСервер.ДополнениеВыгрузкиИмяАвтоСохраненияНастроек());
	
	// Дополнительно регистрируем данные.
	Попытка
		ОбменДаннымиСервер.ИнтерактивноеИзменениеВыгрузкиЗарегистрироватьДополнительныеДанные(ДополнениеВыгрузки);
	Исключение
		Результат.ДанныеЗарегистрированы = Ложь;
		
		Информация = ИнформацияОбОшибке();
		
		Результат.СообщениеОбОшибке = НСтр("ru = 'Возникла проблема при добавлении данных к выгрузке:'") 
			+ Символы.ПС + ОбработкаОшибок.КраткоеПредставлениеОшибки(Информация)
			+ Символы.ПС + НСтр("ru = 'Измените условия отбора.'");
			
		ЗаписьЖурналаРегистрации(ОбменДаннымиСервер.СобытиеЖурналаРегистрацииСозданиеОбменаДанными(),
			УровеньЖурналаРегистрации.Ошибка, , , ОбработкаОшибок.ПодробноеПредставлениеОшибки(Информация));
	КонецПопытки;
	
	ПоместитьВоВременноеХранилище(Результат, АдресРезультата);
	
КонецПроцедуры

Процедура ВыгрузитьДанныеДляСопоставления(Параметры, АдресРезультата) Экспорт
	
	НастройкиВыгрузки = Неопределено;
	Параметры.Свойство("НастройкиВыгрузки", НастройкиВыгрузки);
	
	Результат = Новый Структура;
	Результат.Вставить("ДанныеВыгружены",   Истина);
	Результат.Вставить("СообщениеОбОшибке", "");
	
	ПараметрыОбмена = ОбменДаннымиСервер.ПараметрыОбмена();
	ПараметрыОбмена.ВыполнятьЗагрузку = Ложь;
	ПараметрыОбмена.ВыполнятьВыгрузку = Истина;
	ПараметрыОбмена.ИдентификаторТранспорта = НастройкиВыгрузки.ИдентификаторТранспорта;
	ПараметрыОбмена.НастройкиТранспорта = НастройкиВыгрузки.НастройкиТранспорта;
	
	ПараметрыОбмена.СообщениеДляСопоставленияДанных = Истина;
	
	Если НастройкиВыгрузки.Свойство("ДанныеАутентификации") Тогда
		ПараметрыОбмена.Вставить("ДанныеАутентификации", НастройкиВыгрузки.ДанныеАутентификации);
	КонецЕсли;
	
	Отказ = Ложь;
	Попытка
		ОбменДаннымиСервер.ВыполнитьОбменДаннымиДляУзлаИнформационнойБазы(
			НастройкиВыгрузки.УзелОбмена, ПараметрыОбмена, Отказ);
	Исключение
		Результат.ДанныеВыгружены = Ложь;
		Результат.СообщениеОбОшибке = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		
		ЗаписьЖурналаРегистрации(ОбменДаннымиСервер.СобытиеЖурналаРегистрацииВыгрузкаДанныхДляСопоставления(),
			УровеньЖурналаРегистрации.Ошибка, , , Результат.СообщениеОбОшибке);
	КонецПопытки;
		
	Результат.ДанныеВыгружены = Результат.ДанныеВыгружены И Не Отказ;
	
	Если Не Результат.ДанныеВыгружены
		И ПустаяСтрока(Результат.СообщениеОбОшибке) Тогда
		Результат.СообщениеОбОшибке = НСтр("ru = 'При выполнении выгрузки данных для сопоставления возникли ошибки (см. Журнал регистрации).'");
	КонецЕсли;
	
	ПоместитьВоВременноеХранилище(Результат, АдресРезультата);
	
КонецПроцедуры

#Область РаботаСДлительнымиОперациями

// Для внутреннего использования.
//
Процедура ПриНачалеДлительнойОперации(ФоновоеЗадание, ПараметрыОбработчика, ПродолжитьОжидание = Истина)
	
	ИнициализироватьПараметрыОбработчикаДлительнойОперации(ПараметрыОбработчика, ФоновоеЗадание);
	
	Если ФоновоеЗадание.Статус = "Выполняется" Тогда
		ПараметрыОбработчика.АдресРезультата       = ФоновоеЗадание.АдресРезультата;
		ПараметрыОбработчика.ИдентификаторОперации = ФоновоеЗадание.ИдентификаторЗадания;
		ПараметрыОбработчика.ДлительнаяОперация    = Истина;
		
		ПродолжитьОжидание = Истина;
		Возврат;
	ИначеЕсли ФоновоеЗадание.Статус = "Выполнено" Тогда
		ПараметрыОбработчика.АдресРезультата    = ФоновоеЗадание.АдресРезультата;
		ПараметрыОбработчика.ДлительнаяОперация = Ложь;
		
		ПродолжитьОжидание = Ложь;
		Возврат;
	Иначе
		ПараметрыОбработчика.СообщениеОбОшибке = ФоновоеЗадание.КраткоеПредставлениеОшибки;
		Если ЗначениеЗаполнено(ФоновоеЗадание.ПодробноеПредставлениеОшибки) Тогда
			ПараметрыОбработчика.СообщениеОбОшибке = ФоновоеЗадание.ПодробноеПредставлениеОшибки;
		КонецЕсли;
		
		ПараметрыОбработчика.Отказ = Истина;
		ПараметрыОбработчика.ДлительнаяОперация = Ложь;
		
		ПродолжитьОжидание = Ложь;
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

// Для внутреннего использования.
//
Процедура ПриОжиданииДлительнойОперации(ПараметрыОбработчика, ПродолжитьОжидание = Истина)
	
	Если ПараметрыОбработчика.Отказ
		Или Не ПараметрыОбработчика.ДлительнаяОперация Тогда
		ПродолжитьОжидание = Ложь;
		Возврат;
	КонецЕсли;
	
	ЗаданиеВыполнено = Ложь;
	Попытка
		ЗаданиеВыполнено = ДлительныеОперации.ЗаданиеВыполнено(ПараметрыОбработчика.ИдентификаторОперации);
	Исключение
		ПараметрыОбработчика.Отказ             = Истина;
		ПараметрыОбработчика.СообщениеОбОшибке = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		
		ЗаписьЖурналаРегистрации(ОбменДаннымиСервер.СобытиеЖурналаРегистрацииСозданиеОбменаДанными(),
			УровеньЖурналаРегистрации.Ошибка, , , ПараметрыОбработчика.СообщениеОбОшибке);
	КонецПопытки;
		
	Если ПараметрыОбработчика.Отказ Тогда
		ПродолжитьОжидание = Ложь;
		Возврат;
	КонецЕсли;
	
	ПродолжитьОжидание = Не ЗаданиеВыполнено;
	
КонецПроцедуры

// Для внутреннего использования.
//
Процедура ПриЗавершенииДлительнойОперации(ПараметрыОбработчика,
		СтатусЗавершения = Неопределено)
	
	СтатусЗавершения = Новый Структура;
	СтатусЗавершения.Вставить("Отказ",             Ложь);
	СтатусЗавершения.Вставить("СообщениеОбОшибке", "");
	СтатусЗавершения.Вставить("Результат",         Неопределено);
	
	Если ПараметрыОбработчика.Отказ Тогда
		ЗаполнитьЗначенияСвойств(СтатусЗавершения, ПараметрыОбработчика, "Отказ, СообщениеОбОшибке");
	Иначе
		СтатусЗавершения.Результат = ПолучитьИзВременногоХранилища(ПараметрыОбработчика.АдресРезультата);
	КонецЕсли;
	
	ПараметрыОбработчика = Неопределено;
		
КонецПроцедуры

Процедура ИнициализироватьПараметрыОбработчикаДлительнойОперации(ПараметрыОбработчика, ФоновоеЗадание)
	
	ПараметрыОбработчика = Новый Структура;
	ПараметрыОбработчика.Вставить("ФоновоеЗадание",          ФоновоеЗадание);
	ПараметрыОбработчика.Вставить("Отказ",                   Ложь);
	ПараметрыОбработчика.Вставить("СообщениеОбОшибке",       "");
	ПараметрыОбработчика.Вставить("ДлительнаяОперация",      Ложь);
	ПараметрыОбработчика.Вставить("ИдентификаторОперации",   Неопределено);
	ПараметрыОбработчика.Вставить("АдресРезультата",         Неопределено);
	ПараметрыОбработчика.Вставить("ДополнительныеПараметры", Новый Структура);
	
КонецПроцедуры

Процедура ЗавершитьФоновыеЗадания(КлючФоновогоЗадания, АктивныеФоновыеЗадания)
	
	Паузы = Новый Массив;
	Паузы.Добавить(1);
	Паузы.Добавить(5);
	Паузы.Добавить(10);
	
	Итерация = 0;
	
	Для Каждого ФоновоеЗадание Из АктивныеФоновыеЗадания Цикл
		
		ДлительныеОперации.ОтменитьВыполнениеЗадания(ФоновоеЗадание.УникальныйИдентификатор);
		
		Пока ОбменДаннымиСервер.ЕстьАктивныеФоновыеЗадания(КлючФоновогоЗадания) И Итерация < Паузы.Количество() Цикл
			Пауза = Паузы[Итерация];
			ФоновоеЗадание.ОжидатьЗавершенияВыполнения(Пауза);
			Итерация = Итерация + 1;
		КонецЦикла;
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

// Выполняет анализ входящего сообщения обмена. Заполняет данными таблицу ИнформацияСтатистики.
//
// Параметры:
//   Параметры - Структура
//   Отказ - Булево - флаг отказа; поднимается в случае возникновения ошибок при работе процедуры.
//   РезультатВыполненияОбмена - ПеречислениеСсылка.РезультатыВыполненияОбмена - результат выполнения обмена данными.
//
Функция ТаблицаСтатистикиСообщенияОбмена(Параметры,
		Отказ, РезультатВыполненияОбмена = Неопределено, СообщениеОбОшибке = "")
		
	ИнформацияСтатистики = Неопределено; // ТаблицаЗначений
	ИнициализироватьТаблицуСтатистики(ИнформацияСтатистики);
	
	ИмяВременногоКаталогаСообщенийОбмена = Параметры.ИмяВременногоКаталогаСообщенийОбмена;
	УзелИнформационнойБазы               = Параметры.УзелИнформационнойБазы;
	ИмяФайлаСообщенияОбмена              = Параметры.ИмяФайлаСообщенияОбмена;
	
	Если ПустаяСтрока(ИмяВременногоКаталогаСообщенийОбмена) Тогда
		// Не удалось получить данные из другой программы.
		Отказ = Истина;
		Возврат ИнформацияСтатистики;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	СтруктураНастроекОбмена = ОбменДаннымиСервер.СтруктураНастроекОбменаДляСеансаИнтерактивнойЗагрузки(
		УзелИнформационнойБазы, ИмяФайлаСообщенияОбмена);
	
	Если СтруктураНастроекОбмена.Отказ Тогда
		Возврат ИнформацияСтатистики;
	КонецЕсли;
	
	ОбработкаОбменаДанными = СтруктураНастроекОбмена.ОбработкаОбменаДанными;
	
	ПараметрыАнализа = Новый Структура("СобиратьСтатистикуКлассификаторов", Истина);	
	ОбработкаОбменаДанными.ВыполнитьАнализСообщенияОбмена(ПараметрыАнализа);
	
	РезультатВыполненияОбмена = ОбработкаОбменаДанными.РезультатВыполненияОбмена();
	
	Если ОбработкаОбменаДанными.ФлагОшибки() Тогда
		Отказ = Истина;
		СообщениеОбОшибке = ОбработкаОбменаДанными.СтрокаСообщенияОбОшибке();
		Возврат ИнформацияСтатистики;
	КонецЕсли;
	
	ТаблицаДанныхЗаголовкаПакета = ОбработкаОбменаДанными.ТаблицаДанныхЗаголовкаПакета();
	Для Каждого СтрокаДанныхЗаголовкаПакета Из ТаблицаДанныхЗаголовкаПакета Цикл
		СтрокаИнформацияСтатистики = ИнформацияСтатистики.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаИнформацияСтатистики, СтрокаДанныхЗаголовкаПакета);
	КонецЦикла;
	
	// Дополняем таблицу статистики служебными данными.
	СообщениеОбОшибке = "";
	ДополнитьТаблицуСтатистики(ИнформацияСтатистики, Отказ, СообщениеОбОшибке);
	
	// Определяем строки таблицы с признаком "ОдинКоМногим".
	ИнформацияСтатистикиВременная = ИнформацияСтатистики.Скопировать(, "ИмяТаблицыПриемника, ЭтоУдалениеОбъекта");
	
	ДобавитьКолонкуСоЗначениемВТаблицу(ИнформацияСтатистикиВременная, 1, "Итератор");
	
	ИнформацияСтатистикиВременная.Свернуть("ИмяТаблицыПриемника, ЭтоУдалениеОбъекта", "Итератор");
	
	Для Каждого СтрокаТаблицы Из ИнформацияСтатистикиВременная Цикл
		
		Если СтрокаТаблицы.Итератор > 1 И Не СтрокаТаблицы.ЭтоУдалениеОбъекта Тогда
			
			СтрокиИнформацияСтатистики = ИнформацияСтатистики.НайтиСтроки(Новый Структура("ИмяТаблицыПриемника, ЭтоУдалениеОбъекта",
				СтрокаТаблицы.ИмяТаблицыПриемника, СтрокаТаблицы.ЭтоУдалениеОбъекта));
			
			Для Каждого СтрокаИнформацияСтатистики Из СтрокиИнформацияСтатистики Цикл
				
				СтрокаИнформацияСтатистики["ОдинКоМногим"] = Истина;
				
			КонецЦикла;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат ИнформацияСтатистики;
	
КонецФункции

// Для внутреннего использования.
//
Функция РезультатАвтоматическогоСопоставленияДанных(Знач Корреспондент,
		Знач ИмяФайлаСообщенияОбмена, Знач ИмяВременногоКаталогаСообщенийОбмена, ПроверятьРасхождениеВерсий)
		
	Результат = Новый Структура;
	Результат.Вставить("ИнформацияСтатистики",      Неопределено);
	Результат.Вставить("ВсеДанныеСопоставлены",     Истина);
	Результат.Вставить("ЕстьНеСопоставленнаяНСИ",   Ложь);
	Результат.Вставить("СтатистикаПустая",          Истина);
	Результат.Вставить("Отказ",                     Ложь);
	Результат.Вставить("СообщениеОбОшибке",         "");
	Результат.Вставить("РезультатВыполненияОбмена", Неопределено);
	
	// Выполняем автоматическое сопоставление данных, полученных от корреспондента.
	// Получаем статистику сопоставления.
	УстановитьПривилегированныйРежим(Истина);
	
	ОбменДаннымиСервер.ИнициализироватьПараметрыПроверкиРасхожденияВерсий(ПроверятьРасхождениеВерсий);
	
	// Выполняем анализ сообщения обмена.
	ПараметрыАнализа = Новый Структура;
	ПараметрыАнализа.Вставить("ИмяВременногоКаталогаСообщенийОбмена", ИмяВременногоКаталогаСообщенийОбмена);
	ПараметрыАнализа.Вставить("УзелИнформационнойБазы",               Корреспондент);
	ПараметрыАнализа.Вставить("ИмяФайлаСообщенияОбмена",              ИмяФайлаСообщенияОбмена);
	
	ИнформацияСтатистики = ТаблицаСтатистикиСообщенияОбмена(ПараметрыАнализа,
		Результат.Отказ, Результат.РезультатВыполненияОбмена, Результат.СообщениеОбОшибке);
	
	Если Результат.Отказ Тогда
		Если ПараметрыСеанса.ОшибкаРасхожденияВерсийПриПолученииДанных.ЕстьОшибка Тогда
			Возврат ПараметрыСеанса.ОшибкаРасхожденияВерсийПриПолученииДанных;
		КонецЕсли;
		
		Возврат Результат;
	КонецЕсли;
	
	ПомощникИнтерактивногоОбменаДанными = Создать();
	ПомощникИнтерактивногоОбменаДанными.УзелИнформационнойБазы = Корреспондент;
	ПомощникИнтерактивногоОбменаДанными.ИмяФайлаСообщенияОбмена = ИмяФайлаСообщенияОбмена;
	ПомощникИнтерактивногоОбменаДанными.ИмяВременногоКаталогаСообщенийОбмена = ИмяВременногоКаталогаСообщенийОбмена;
	ПомощникИнтерактивногоОбменаДанными.ИмяПланаОбмена = ОбменДаннымиПовтИсп.ПолучитьИмяПланаОбмена(Корреспондент);
	ПомощникИнтерактивногоОбменаДанными.ИдентификаторТранспорта = "";
	
	ПомощникИнтерактивногоОбменаДанными.ИнформацияСтатистики.Загрузить(ИнформацияСтатистики);
	
	// Выполняем автоматическое сопоставление и получаем статистику сопоставления.
	ПомощникИнтерактивногоОбменаДанными.ВыполнитьАвтоматическоеСопоставлениеПоУмолчаниюИПолучитьСтатистикуСопоставления(Результат.Отказ);
	
	Если Результат.Отказ Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось загрузить данные из ""%1"" (этап автоматического сопоставления данных).'"),
			Строка(Корреспондент));
	КонецЕсли;
	
	ТаблицаИнформацииСтатистики = ПомощникИнтерактивногоОбменаДанными.ТаблицаИнформацииСтатистики();
	
	Результат.ИнформацияСтатистики    = ТаблицаИнформацииСтатистики;
	Результат.ВсеДанныеСопоставлены   = ВсеДанныеСопоставлены(ТаблицаИнформацииСтатистики);
	Результат.СтатистикаПустая        = (ТаблицаИнформацииСтатистики.Количество() = 0);
	Результат.ЕстьНеСопоставленнаяНСИ = ЕстьНеСопоставленнаяНСИ(ТаблицаИнформацииСтатистики);
	
	Возврат Результат;
	
КонецФункции

Процедура ИнициализироватьТаблицуСтатистики(ТаблицаСтатистики)
	
	ТаблицаСтатистики = Новый ТаблицаЗначений;
	ТаблицаСтатистики.Колонки.Добавить("ДанныеУспешноЗагружены", Новый ОписаниеТипов("Булево"));
	ТаблицаСтатистики.Колонки.Добавить("ИмяТаблицыПриемника", Новый ОписаниеТипов("Строка"));
	ТаблицаСтатистики.Колонки.Добавить("ИндексКартинки", Новый ОписаниеТипов("Число"));
	ТаблицаСтатистики.Колонки.Добавить("ИспользоватьПредварительныйПросмотр", Новый ОписаниеТипов("Булево"));
	ТаблицаСтатистики.Колонки.Добавить("Ключ", Новый ОписаниеТипов("Строка"));
	ТаблицаСтатистики.Колонки.Добавить("КоличествоОбъектовВИсточнике", Новый ОписаниеТипов("Число"));
	ТаблицаСтатистики.Колонки.Добавить("КоличествоОбъектовВПриемнике", Новый ОписаниеТипов("Число"));
	ТаблицаСтатистики.Колонки.Добавить("КоличествоОбъектовНесопоставленных", Новый ОписаниеТипов("Число"));
	ТаблицаСтатистики.Колонки.Добавить("КоличествоОбъектовСопоставленных", Новый ОписаниеТипов("Число"));
	ТаблицаСтатистики.Колонки.Добавить("ОдинКоМногим", Новый ОписаниеТипов("Булево"));
	ТаблицаСтатистики.Колонки.Добавить("ПоляПоиска", Новый ОписаниеТипов("Строка"));
	ТаблицаСтатистики.Колонки.Добавить("ПоляТаблицы", Новый ОписаниеТипов("Строка"));
	ТаблицаСтатистики.Колонки.Добавить("Представление", Новый ОписаниеТипов("Строка"));
	ТаблицаСтатистики.Колонки.Добавить("ПроцентСопоставленияОбъектов", Новый ОписаниеТипов("Число"));
	ТаблицаСтатистики.Колонки.Добавить("СинхронизироватьПоИдентификатору", Новый ОписаниеТипов("Булево"));
	ТаблицаСтатистики.Колонки.Добавить("ТипИсточникаСтрокой", Новый ОписаниеТипов("Строка"));
	ТаблицаСтатистики.Колонки.Добавить("ТипОбъектаСтрокой", Новый ОписаниеТипов("Строка"));
	ТаблицаСтатистики.Колонки.Добавить("ТипПриемникаСтрокой", Новый ОписаниеТипов("Строка"));
	ТаблицаСтатистики.Колонки.Добавить("ЭтоКлассификатор", Новый ОписаниеТипов("Булево"));
	ТаблицаСтатистики.Колонки.Добавить("ЭтоУдалениеОбъекта", Новый ОписаниеТипов("Булево"));
	ТаблицаСтатистики.Колонки.Добавить("ЭтоНСИ", Новый ОписаниеТипов("Булево"));
	
КонецПроцедуры

Процедура ДополнитьТаблицуСтатистики(ИнформацияСтатистики, Отказ, СообщениеОбОшибке = "")
	
	Для Каждого СтрокаТаблицы Из ИнформацияСтатистики Цикл
		
		Попытка
			Тип = Тип(СтрокаТаблицы.ТипОбъектаСтрокой);
		Исключение
			Отказ = Истина;
			СообщениеОбОшибке = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Ошибка: тип ""%1"" не определен.'"), СтрокаТаблицы.ТипОбъектаСтрокой);
			Прервать;
		КонецПопытки;
		
		МетаданныеОбъекта = Метаданные.НайтиПоТипу(Тип);
		
		СтрокаТаблицы.ИмяТаблицыПриемника = МетаданныеОбъекта.ПолноеИмя();
		СтрокаТаблицы.Представление       = МетаданныеОбъекта.Представление();
		
		СтрокаТаблицы.Ключ = Строка(Новый УникальныйИдентификатор);
		
	КонецЦикла;
	
КонецПроцедуры

// Параметры:
//   Таблица - ТаблицаЗначений
//   ЗначениеИтератора - Число
//   ИмяПоляИтератора - Строка
//
Процедура ДобавитьКолонкуСоЗначениемВТаблицу(Таблица, ЗначениеИтератора, ИмяПоляИтератора)
	
	Таблица.Колонки.Добавить(ИмяПоляИтератора);
	
	Таблица.ЗаполнитьЗначения(ЗначениеИтератора, ИмяПоляИтератора);
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли

