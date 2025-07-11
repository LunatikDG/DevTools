///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Открывает конструктор формул.
//
// Параметры:
//  Параметры - см. ПараметрыРедактированияФормулы
//  ОбработчикЗавершения - ОписаниеОповещения 
//
Процедура НачатьРедактированиеФормулы(Параметры, ОбработчикЗавершения) Экспорт
	
	ОткрытьФорму("Обработка.КонструкторФормул.Форма.РедактированиеФормулы", Параметры, , , , , ОбработчикЗавершения);
	
КонецПроцедуры

// Конструктор параметра ПараметрыФормулы для функции ПредставлениеФормулы.
// 
// Возвращаемое значение:
//  Структура:
//   * Формула - Строка
//   * Операнды - Строка - адрес во временном хранилище коллекции операндов. Коллекция может быть одного из трех типов: 
//                         ТаблицаЗначений - см. ТаблицаПолей
//                         ДеревоЗначений - см. ДеревоПолей
//                         СхемаКомпоновкиДанных  - список операндов будет взят из коллекции ДоступныеПоляОтбора
//                                                  компоновщика настроек. Имя коллекции может быть переопределено
//                                                  в параметре ИмяКоллекцииСКД.
//   * Операторы - Строка - адрес во временном хранилище коллекции операторов. Коллекция может быть одного из трех типов: 
//                         ТаблицаЗначений - см. ТаблицаПолей
//                         ДеревоЗначений - см. ДеревоПолей
//                         СхемаКомпоновкиДанных  - список операндов будет взят из коллекции ДоступныеПоляОтбора
//                                                  компоновщика настроек. Имя коллекции может быть переопределено
//                                                  в параметре ИмяКоллекцииСКД.
//   * ИмяКоллекцииСКДОперандов  - Строка - имя коллекции полей в компоновщике настроек. Параметр необходимо
//                                          использовать, если в параметре Операнды передана схема компоновки данных.
//                                          Значение по умолчанию - ДоступныеПоляОтбора.
//   * ИмяКоллекцииСКДОператоров - Строка - имя коллекции полей в компоновщике настроек. Параметр необходимо
//                                          использовать, если в параметре Операторы передана схема компоновки данных.
//                                          Значение по умолчанию - ДоступныеПоляОтбора.
//   * Наименование - Неопределено - наименование не используется для формулы, соответствующее поле не выводится.
//                  - Строка       - наименование формулы. Если заполнено или пустое, соответствующее поле выводится
//                                   на в форме конструктора.
//   * ДляЗапроса   - Булево - формула предназначена для вставки в запрос. Данный параметр влияет на состав операторов
//                             по умолчанию, а также на выбор алгоритма проверки формулы.
//
Функция ПараметрыРедактированияФормулы() Экспорт
	
	Возврат КонструкторФормулКлиентСервер.ПараметрыРедактированияФормулы();
	
КонецФункции

// Обработчик разворачивания подключаемого списка.
// 
// Параметры:
//  Форма   - ФормаКлиентскогоПриложения - владелец списка.
//  Элемент - ТаблицаФормы - список, в котором выполняется разворачивание строки.
//  Строка  - Число - идентификатор строки списка.
//  Отказ   - Булево - признак отказа от разворачивания.
//
Процедура СписокПолейПередРазворачиванием(Форма, Элемент, Строка, Отказ) Экспорт
	
	НастройкиСпискаПолей = НастройкиСпискаПолей(Форма, Элемент.Имя);
	КоллекцияЭлементов = Форма[Элемент.Имя].НайтиПоИдентификатору(Строка).ПолучитьЭлементы();
	Если КоллекцияЭлементов.Количество() > 0 И КоллекцияЭлементов[0].Поле = Неопределено Тогда
		Отказ = Истина;
		НастройкиСпискаПолей.РазворачиваемыеВетки = НастройкиСпискаПолей.РазворачиваемыеВетки + Формат(Строка, "ЧН=0; ЧГ=0;") + ";";
		Форма.ПодключитьОбработчикОжидания("Подключаемый_РазвернутьТекущийЭлементСпискаПолей", 0.1, Истина);
	КонецЕсли;
	
КонецПроцедуры

// Обработчик разворачивания подключаемого списка.
// Разворачивает текущий элемент списка.
//
// Параметры:
//  Форма - ФормаКлиентскогоПриложения
// 
Процедура РазвернутьТекущийЭлементСпискаПолей(Форма) Экспорт
	
	Для Каждого ПодключенныйСписокПолей Из Форма.ПодключенныеСпискиПолей Цикл
		СписокПолей = Форма.Элементы[ПодключенныйСписокПолей.ИмяСпискаПолей];
		
		Для Каждого ИдентификаторСтроки Из СтрРазделить(ПодключенныйСписокПолей.РазворачиваемыеВетки, ";", Ложь) Цикл
			ПараметрыЗаполнения = Новый Структура;
			ПараметрыЗаполнения.Вставить("ИдентификаторСтроки", ИдентификаторСтроки);
			ПараметрыЗаполнения.Вставить("ИмяСписка", СписокПолей.Имя);
			
			Форма.Подключаемый_ЗаполнитьСписокДоступныхПолей(ПараметрыЗаполнения);
			СписокПолей.Развернуть(ИдентификаторСтроки);
		КонецЦикла;
		
		ПодключенныйСписокПолей.РазворачиваемыеВетки = "";
	КонецЦикла;
	
КонецПроцедуры

// Обработчик перетаскивания подключаемого списка
// 
// Параметры:
//  Форма   - ФормаКлиентскогоПриложения - владелец списка.
//  Элемент - ТаблицаФормы - список, в котором выполняется перетаскивание.
//  ПараметрыПеретаскивания - ПараметрыПеретаскивания - содержит перетаскиваемое значение, тип действия 
//                                                      и возможные действия при перетаскивании.
//  Выполнение - Булево - если Ложь, перетаскивание не начнется.
//
Процедура СписокПолейНачалоПеретаскивания(Форма, Элемент, ПараметрыПеретаскивания, Выполнение) Экспорт
	
	ИмяСпискаПолей = Элемент.Имя;
	Реквизит = Форма[ИмяСпискаПолей].НайтиПоИдентификатору(ПараметрыПеретаскивания.Значение);
	
	НастройкиСпискаПолей = КонструкторФормулКлиентСервер.НастройкиСпискаПолей(Форма, ИмяСпискаПолей);
	Если НастройкиСпискаПолей.СкобкиПредставлений Тогда
		ПараметрыПеретаскивания.Значение = "[" + Реквизит.ПредставлениеПутиКДанным + "]";
	Иначе
		ПараметрыПеретаскивания.Значение = Реквизит.ПредставлениеПутиКДанным;
	КонецЕсли;
	
КонецПроцедуры

// Возвращает описание текущего выбранного поля подключаемого списка.
//
// Параметры:
//  Форма - ФормаКлиентскогоПриложения - владелец списка.
//  ИмяСпискаПолей - Строка - имя списка, установленное при вызове КонструкторФормул.ДобавитьСписокПолейНаФорму.
//  
// Возвращаемое значение:
//  Структура:
//   * Имя - Строка
//   * Заголовок - Строка
//   * ПутьКДанным - Строка
//   * ПредставлениеПутиКДанным - Строка
//   * Тип - ОписаниеТипов
//   * Родитель - см. ВыбранноеПолеВСпискеПолей
//
Функция ВыбранноеПолеВСпискеПолей(Форма, ИмяСпискаПолей = Неопределено) Экспорт
	
	Если Форма.ПодключенныеСпискиПолей.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Если ИмяСпискаПолей = Неопределено Тогда
		СписокПолей = Форма.ТекущийЭлемент; // ТаблицаФормы
		ИмяСпискаПолей = СписокПолей.Имя;
		Если КонструкторФормулКлиентСервер.НастройкиСпискаПолей(Форма, ИмяСпискаПолей)= Неопределено Тогда
			ИмяСпискаПолей = Форма.ПодключенныеСпискиПолей[0].ИмяСпискаПолей;
		КонецЕсли;
	КонецЕсли;
	
	СписокПолей = Форма.Элементы[ИмяСпискаПолей];
	ТекущиеДанные = СписокПолей.ТекущиеДанные;
	
	Если ТекущиеДанные = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат ОписаниеВыбранногоПоля(ТекущиеДанные);
	
КонецФункции

// Обработчик события строки поиска подключаемого списка.
// 
// Параметры:
//  Форма   - ФормаКлиентскогоПриложения - владелец списка.
//  Элемент - ПолеФормы - строка поиска.
//  Текст - Строка - текст в строке поиска.
//  СтандартнаяОбработка - Булево - если Ложь, стандартное действие выполнено не будет.
//
Процедура СтрокаПоискаИзменениеТекстаРедактирования(Форма, Элемент, Текст, СтандартнаяОбработка) Экспорт
	
	АктуализироватьИмяСтрокиПоиска(Форма, Элемент.Имя);
	
	Форма[Форма.ИмяТекущейСтрокиПоиска] = Текст;
	
	Форма.ОтключитьОбработчикОжидания("Подключаемый_ВыполнитьПоискВСпискеПолей");
	Форма.ОтключитьОбработчикОжидания("Подключаемый_НачатьПоискВСпискеПолей");
	ПараметрыПодключенногоСпискаПолей = ПараметрыПодключенногоСпискаПолей(Форма, Форма.ИмяТекущейСтрокиПоиска);
	Если ПараметрыПодключенногоСпискаПолей.ИспользоватьФоновыйПоиск Тогда
		Форма.ПодключитьОбработчикОжидания("Подключаемый_НачатьПоискВСпискеПолей", 0.5, Истина);
	Иначе
		Форма.ПодключитьОбработчикОжидания("Подключаемый_ВыполнитьПоискВСпискеПолей", 0.5, Истина);
	КонецЕсли;
	
КонецПроцедуры

// Обработчик события строки поиска подключаемого списка.
// 
// Параметры:
//  Форма   - ФормаКлиентскогоПриложения - владелец списка.
//  Элемент - КнопкаФормы - кнопка очистки.
//  УдалитьСтандартнаяОбработка - Булево - параметр устарел
//
Процедура СтрокаПоискаОчистка(Форма, Элемент, УдалитьСтандартнаяОбработка = Неопределено) Экспорт

	АктуализироватьИмяСтрокиПоиска(Форма, Элемент.Имя);
	
	ПодключенныйСписокПолей = ПараметрыПодключенногоСпискаПолей(Форма, Форма.ИмяТекущейСтрокиПоиска);
	
	ДополнительныеПараметры = ПараметрыОбработчика();
	ДополнительныеПараметры.ВыполнитьНаСервере = Истина;
	ДополнительныеПараметры.КлючОперации = "ОчиститьСтрокуПоиска";
	Форма.Подключаемый_ОбработчикКонструктораФормулКлиент(Элемент.Имя, ДополнительныеПараметры);
	Элемент = Форма.Элементы[СтрЗаменить(Элемент.Имя, "Очистка", "")];
	Элемент.ОбновитьТекстРедактирования();
	
	СтрокаПоискаИзменениеТекстаРедактирования(Форма, Элемент, "", УдалитьСтандартнаяОбработка);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// Параметры:
//  Оператор - см. ВыбранноеПолеВСпискеПолей
//
Функция ВыражениеДляВставки(Оператор) Экспорт
	
	Если ЗначениеЗаполнено(Оператор.ВыражениеДляВставки) Тогда
		Возврат Оператор.ВыражениеДляВставки;
	КонецЕсли;
	
	Результат = Оператор.Заголовок + "()";
	
	Если Не ЗначениеЗаполнено(Оператор.Родитель) Тогда
		Возврат "";
	КонецЕсли;
	
	ГруппаОператоров = Оператор.Родитель; // см. ВыбранноеПолеВСпискеПолей
	ИмяГруппыОператоров = ГруппаОператоров.Имя;
	
	Если ИмяГруппыОператоров = "Разделители" Тогда
		Результат = "+ """ + Оператор.Заголовок + """ +";
		Если Оператор.Имя = "[ ]" Тогда
			Результат = "+ "" "" +";
		КонецЕсли;
	КонецЕсли;
	
	Если ИмяГруппыОператоров = "ЛогическиеОператорыИКонстанты"
		Или ИмяГруппыОператоров = "Операторы"
		Или ИмяГруппыОператоров = "ОперацииНадСтроками"
		Или ИмяГруппыОператоров = "ЛогическиеОперации"
		Или ИмяГруппыОператоров = "ОперацииСравнения" И Оператор.Имя <> "В" Тогда
		Результат = Оператор.Заголовок;
	КонецЕсли;
	
	Если ИмяГруппыОператоров = "ПрочиеФункции" Тогда
		Если Оператор.Имя = "[?]" Или Оператор.Имя = "Формат" Тогда
			Результат = Оператор.Заголовок + "(,,)";
		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Запуск фонового поиска
// Параметры:
//  Форма   - ФормаКлиентскогоПриложения - форма в которой производится поиск.
//
Процедура НачатьПоискВСпискеПолей(Форма) Экспорт
	
	ИмяСтрокиПоиска = Форма.ИмяТекущейСтрокиПоиска;
	ПодключенныйСписокПолей = ПараметрыПодключенногоСпискаПолей(Форма, Форма.ИмяТекущейСтрокиПоиска);
	
	Отбор = Форма[Форма.ИмяТекущейСтрокиПоиска];
	ДлинаСтрокиОтбора = СтрДлина(Отбор);
	
	СообщениеСтрокиОжидания = НСтр("ru = 'Продолжите ввод...'");
	
	ИмяСпискаПолей = ПодключенныйСписокПолей.ИмяСпискаПолей;
	ДеревоНаФорме = Форма[ИмяСпискаПолей];
	СписокПолей = Форма.Элементы[ИмяСпискаПолей];
	
	Если ДлинаСтрокиОтбора >= ПодключенныйСписокПолей.КоличествоСимволовДляНачалаПоиска Тогда
		
		ИспользоватьПредварительныйОтбор = Истина;
		СтрокаРезультатовПоиска = КонструкторФормулКлиентСервер.СтрокаРезультатовПоиска(ДеревоНаФорме);
		Если СтрокаРезультатовПоиска.Заголовок <> "" И СтрНачинаетсяС(Отбор, СтрокаРезультатовПоиска.Заголовок)
			И СтрРазделить(Отбор, ".").Количество() = 1 Тогда
			УстановитьПредварительныйОтбор(СтрокаРезультатовПоиска, Отбор, СтрокаРезультатовПоиска);
			ИспользоватьПредварительныйОтбор = Ложь;
		Иначе
			СтрокаРезультатовПоиска.ПолучитьЭлементы().Очистить();
		КонецЕсли;
		СтрокаРезультатовПоиска.Заголовок = Отбор;
		ДополнительныеПараметры = ПараметрыОбработчика();
		ДополнительныеПараметры.ВыполнитьНаСервере = Истина;
		ДополнительныеПараметры.КлючОперации = "ЗапуститьФоновыйПоискВСпискеПолей";
		
		ДлительнаяОперация = Неопределено;
		
		Форма.Подключаемый_ОбработчикКонструктораФормулКлиент(ДлительнаяОперация, ДополнительныеПараметры);
		
		
		Если ДлительнаяОперация <> Неопределено Тогда 
			ПараметрыЗавершения = Новый Структура("Форма, ИдентификаторЗадания", Форма, ДлительнаяОперация.ИдентификаторЗадания);
			
			Если ДлительнаяОперация.Статус = "Выполнено" Тогда
				ЗавершениеПоискаВСпискеПолей(ДлительнаяОперация, ПараметрыЗавершения);
				ИспользоватьПредварительныйОтбор = Ложь;
			Иначе
				ОповещениеЗавершения = Новый ОписаниеОповещения("ЗавершениеПоискаВСпискеПолей", ЭтотОбъект, ПараметрыЗавершения);
				ОповещениеОПрогрессеВыполнения = Новый ОписаниеОповещения("ОбработкаПоискаВСпискеПолей", ЭтотОбъект, Форма); 
				
				ПараметрыОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(Форма);
				ПараметрыОжидания.ТекстСообщения = НСтр("ru = 'Поиск полей'");
				ПараметрыОжидания.ОповещениеПользователя.Показать = Ложь;
				ПараметрыОжидания.ВыводитьОкноОжидания = Ложь;
				ПараметрыОжидания.ВыводитьСообщения = Ложь;
				ПараметрыОжидания.ОповещениеОПрогрессеВыполнения = ОповещениеОПрогрессеВыполнения;
				
				ДлительныеОперацииКлиент.ОжидатьЗавершение(ДлительнаяОперация, ОповещениеЗавершения, ПараметрыОжидания);
				Форма.Элементы[ИмяСтрокиПоиска+"Очистка"].Картинка = БиблиотекаКартинок.ДлительнаяОперация16;
			КонецЕсли;
		КонецЕсли;
		
		Если ИспользоватьПредварительныйОтбор Тогда
			СтрокаРезультатовПоиска = КонструкторФормулКлиентСервер.СтрокаРезультатовПоиска(ДеревоНаФорме);
			УстановитьПредварительныйОтбор(ДеревоНаФорме, Отбор, СтрокаРезультатовПоиска);
		КонецЕсли;
		Форма.Элементы[ИмяСпискаПолей+ "Представление"].Видимость = Ложь;
		Форма.Элементы[ИмяСпискаПолей+ "ПредставлениеПутиКДанным"].Видимость = Истина;
		СписокПолей.Отображение = ОтображениеТаблицы.Список;
		УдалитьСтрокуОжидания(ДеревоНаФорме, СообщениеСтрокиОжидания);
		
	ИначеЕсли ДлинаСтрокиОтбора = 0 Тогда
		СброситьРезультатыПоиска(ДеревоНаФорме);
		УдалитьСтрокуОжидания(ДеревоНаФорме, СообщениеСтрокиОжидания);
		Форма.Элементы[ИмяСпискаПолей+ "Представление"].Видимость = Истина;
		Форма.Элементы[ИмяСпискаПолей+ "ПредставлениеПутиКДанным"].Видимость = Ложь;
		СписокПолей.Отображение = ОтображениеТаблицы.Дерево;
	Иначе
		СброситьРезультатыПоиска(ДеревоНаФорме);
		ДобавитьСтрокуОжидания(ДеревоНаФорме, СообщениеСтрокиОжидания);
		Форма.Элементы[ИмяСпискаПолей+ "Представление"].Видимость = Истина;
		Форма.Элементы[ИмяСпискаПолей+ "ПредставлениеПутиКДанным"].Видимость = Ложь;
		СписокПолей.Отображение = ОтображениеТаблицы.Список;
	КонецЕсли;
КонецПроцедуры

// Обработчик завершения поиска в списке полей.
// 
// Параметры:
//  Результат - см. ДлительныеОперацииКлиент.НовыйРезультатДлительнойОперации
//  ПараметрыЗавершения - Структура:
//    * Форма - ФормаКлиентскогоПриложения
//    * ИдентификаторЗадания - УникальныйИдентификатор - идентификатор фонового задания.
//
Процедура ЗавершениеПоискаВСпискеПолей(Результат, ПараметрыЗавершения) Экспорт
	
	ИдентификаторЗадания = ПараметрыЗавершения.ИдентификаторЗадания;
	Форма = ПараметрыЗавершения.Форма;
	
	СоответствиеЗаданий = ПолучитьИзВременногоХранилища(Форма.АдресОписанияДлительнойОперации);
	Для Каждого Задание Из СоответствиеЗаданий Цикл
		Если Задание.Значение = ИдентификаторЗадания Тогда
			ИмяСтрокиПоиска = Задание.Ключ;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Если ИмяСтрокиПоиска = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Форма.Элементы[ИмяСтрокиПоиска+"Очистка"].Картинка = БиблиотекаКартинок.ПолеВводаОчистить;
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Результат.Статус = "Ошибка" Тогда
		СтандартныеПодсистемыКлиент.ВывестиИнформациюОбОшибке(
			Результат.ИнформацияОбОшибке);
		Возврат;
	КонецЕсли;
	
	Если Результат.Сообщения <> Неопределено Тогда
		ОбработатьСообщения(Форма, Результат.Сообщения, ИдентификаторЗадания);
	КонецЕсли;

	ОбработатьРезультат(Форма, Результат.АдресРезультата, ИдентификаторЗадания);
			
КонецПроцедуры

// Обработка поиска в списке полей.
// 
// Параметры:
//  Результат - см. ДлительныеОперацииКлиент.НовоеСостояниеДлительнойОперации
//  Форма - ФормаКлиентскогоПриложения - форма в которой производиться поиск
//
Процедура ОбработкаПоискаВСпискеПолей(Результат, Форма) Экспорт
		
	Если Результат.Статус <> "Выполняется" Тогда
		Возврат;
	КонецЕсли;
	
	ИдентификаторЗадания = Результат.ИдентификаторЗадания;
	
	ИмяСтрокиПоиска = "";
	СоответствиеЗаданий = ПолучитьИзВременногоХранилища(Форма.АдресОписанияДлительнойОперации);
	Для Каждого Задание Из СоответствиеЗаданий Цикл
		Если Задание.Значение = ИдентификаторЗадания Тогда
			ИмяСтрокиПоиска = Задание.Ключ;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Если ЗначениеЗаполнено(ИмяСтрокиПоиска) Тогда
		Форма.Элементы[ИмяСтрокиПоиска+"Очистка"].Картинка = БиблиотекаКартинок.ДлительнаяОперация16;
		ПодключенныйСписокПолей = ПараметрыПодключенногоСпискаПолей(Форма, ИмяСтрокиПоиска);
		
		ДлинаСтрокиОтбора = СтрДлина(Форма[ИмяСтрокиПоиска]);
		
		Если ДлинаСтрокиОтбора < ПодключенныйСписокПолей.КоличествоСимволовДляНачалаПоиска Тогда
			Форма.Элементы[ИмяСтрокиПоиска+"Очистка"].Картинка = БиблиотекаКартинок.ПолеВводаОчистить;
			Возврат;
		Иначе
			Форма.Элементы[ИмяСтрокиПоиска+"Очистка"].Картинка = БиблиотекаКартинок.ДлительнаяОперация16;
		КонецЕсли;
	КонецЕсли;
	
	Если Результат.Сообщения <> Неопределено Тогда
		ОбработатьСообщения(Форма, Результат.Сообщения, ИдентификаторЗадания);
	КонецЕсли;
	
КонецПроцедуры

// Универсальный обработчик конструктора формул.
// 
// Параметры:
//  Форма - ФормаКлиентскогоПриложения
//  Параметр - Произвольный
//  ДополнительныеПараметры - см. ПараметрыОбработчика
//
Процедура ОбработчикКонструктораФормул(Форма, Параметр, ДополнительныеПараметры) Экспорт
	Если ДополнительныеПараметры = Неопределено Тогда
		ДополнительныеПараметры = ПараметрыОбработчика();
	КонецЕсли;
	
	Если ДополнительныеПараметры.ВыполнитьНаСервере = Истина Тогда
		Возврат;
	КонецЕсли;
	
	КлючОперации = ДополнительныеПараметры.КлючОперации;
	Если КлючОперации = "ОбработатьСообщениеПоиска" Тогда	
		Сообщения = Параметр.Сообщения;
		ИдентификаторЗадания = Параметр.ИдентификаторЗадания;
		ОбработатьСообщенияПоиска(Форма, Сообщения, ИдентификаторЗадания);
	ИначеЕсли КлючОперации = "ОбработатьРезультатПоиска" Тогда	
		АдресРезультата = Параметр.АдресРезультата;
		ИдентификаторЗадания = Параметр.ИдентификаторЗадания;
		ОбработатьРезультатПоиска(Форма, АдресРезультата, ИдентификаторЗадания);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ОписаниеВыбранногоПоля(Поле)
	
	Результат = Новый Структура;
	Результат.Вставить("Имя");
	Результат.Вставить("Заголовок");
	Результат.Вставить("ПутьКДанным");
	Результат.Вставить("ПредставлениеПутиКДанным");
	Результат.Вставить("Тип");
	Результат.Вставить("Родитель");
	Результат.Вставить("ВыражениеДляВставки");
	
	ЗаполнитьЗначенияСвойств(Результат, Поле);
	
	Родитель = Поле.ПолучитьРодителя();
	Если Родитель <> Неопределено Тогда
		Результат.Родитель = ОписаниеВыбранногоПоля(Родитель);
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Процедура ОбработатьСообщения(Форма, Сообщения, ИдентификаторЗадания)
	ДополнительныеПараметры = ПараметрыОбработчика();
	ДополнительныеПараметры.КлючОперации = "ОбработатьСообщениеПоиска";
	ДополнительныеПараметры.ВыполнитьНаСервере = Ложь;
	
	СтруктураПараметра = Новый Структура("Сообщения, ИдентификаторЗадания");
	СтруктураПараметра.Сообщения = Сообщения;
	СтруктураПараметра.ИдентификаторЗадания = ИдентификаторЗадания;
	
	Форма.Подключаемый_ОбработчикКонструктораФормулКлиент(СтруктураПараметра, ДополнительныеПараметры);
КонецПроцедуры

Процедура ОбработатьРезультат(Форма, АдресРезультата, ИдентификаторЗадания)
	ДополнительныеПараметры = ПараметрыОбработчика();
	ДополнительныеПараметры.КлючОперации = "ОбработатьРезультатПоиска";
	ДополнительныеПараметры.ВыполнитьНаСервере = Ложь;
	
	СтруктураПараметра = Новый Структура("АдресРезультата, ИдентификаторЗадания");
	СтруктураПараметра.АдресРезультата = АдресРезультата;
	СтруктураПараметра.ИдентификаторЗадания = ИдентификаторЗадания;
	
	Форма.Подключаемый_ОбработчикКонструктораФормулКлиент(СтруктураПараметра, ДополнительныеПараметры);
КонецПроцедуры

Функция ПараметрыПодключенногоСпискаПолей(Форма, ИмяРеквизита)
	ИмяСпискаПолей = ИмяРеквизитаСпискаПолей(ИмяРеквизита);
	Если СтрЗаканчиваетсяНа(ИмяСпискаПолей, "Очистка") Тогда
		ИмяСпискаПолей = СтрЗаменить(ИмяСпискаПолей+" ", "Очистка ", "");
	КонецЕсли;
	
	ОтборСтрок = Новый Структура("ИмяСпискаПолей", ИмяСпискаПолей);
	СтрокаСпискаПолей = Форма.ПодключенныеСпискиПолей.НайтиСтроки(ОтборСтрок);
	ПодключенныйСписокПолей = СтрокаСпискаПолей[0];
	Возврат ПодключенныйСписокПолей;
КонецФункции

Функция ИмяРеквизитаСпискаПолей(ИмяСтрокиПоискаСпискаПолей)
	
	Результат = СтрЗаменить(ИмяСтрокиПоискаСпискаПолей, "СтрокаПоиска", "");
	
	Возврат Результат;
	
КонецФункции

Процедура АктуализироватьИмяСтрокиПоиска(Форма, Имя)
	УдаляемоеОкончание = "Очистка";
	Если СтрЗаканчиваетсяНа(Имя, УдаляемоеОкончание) Тогда
		ДлинаИмени = СтрДлина(Имя) - СтрДлина(УдаляемоеОкончание);
		Форма.ИмяТекущейСтрокиПоиска = Лев(Имя, ДлинаИмени); 
	Иначе
		Форма.ИмяТекущейСтрокиПоиска = Имя;
	КонецЕсли;
КонецПроцедуры

Функция НастройкиСпискаПолей(Форма, ИмяСпискаПолей)
	
	Для Каждого ПодключенныйСписокПолей Из Форма.ПодключенныеСпискиПолей Цикл
		Если ИмяСпискаПолей = ПодключенныйСписокПолей.ИмяСпискаПолей Тогда
			Возврат ПодключенныйСписокПолей;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Неопределено;
	
КонецФункции

Процедура ОбработатьСообщенияПоиска(Форма, Сообщения, ИдентификаторЗадания)
	
	ИмяСтрокиПоиска = ИмяСтрокиПоискаПоИдентификаторуЗадания(Форма, ИдентификаторЗадания);
	Если ИмяСтрокиПоиска = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ИмяСписка = ИмяРеквизитаСпискаПолей(ИмяСтрокиПоиска);
	ДеревоПолей = Форма[ИмяСписка];
	ДанныеДляФоновогоПоиска = КонструкторФормулВызовСервера.ДанныеДляФоновогоПоиска(Сообщения);
	ДеСериализованныеСообщения = ДанныеДляФоновогоПоиска.ДесериализованныеСообщения;
	
	СтрокаРезультатовПоиска = КонструкторФормулКлиентСервер.СтрокаРезультатовПоиска(ДеревоПолей);
	
	Для ИндексСообщения = 0 По Сообщения.ВГраница() Цикл
		Результат = ДесериализованныеСообщения[ИндексСообщения]; 
		Если ТипЗнч(Результат) <> Тип("Структура") Тогда
			Возврат;
		КонецЕсли;
						
		Если Результат.Свойство("НайденныеЭлементы") Тогда
			НайденныеЭлементы = Результат.НайденныеЭлементы;
			Для Каждого НайденныйЭлемент Из НайденныеЭлементы Цикл
				ДобавляемыйЭлемент = ДобавитьНайденнуюСтроку(СтрокаРезультатовПоиска, НайденныйЭлемент);
				ЗаполнитьЗначенияСвойств(ДобавляемыйЭлемент, НайденныйЭлемент);
				ДобавляемыйЭлемент.СоответствуетОтбору = Истина;
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;
	КонструкторФормулКлиентСервер.СортироватьПоКолонке(СтрокаРезультатовПоиска, "Вес");
	УстановитьТекущуюСтрокуНаПервуюНайденную(Форма.Элементы[ИмяСписка], ДеревоПолей);
КонецПроцедуры

Процедура ОбработатьРезультатПоиска(Форма, АдресРезультата, ИдентификаторЗадания)
	
	РезультатПоиска = ПолучитьИзВременногоХранилища(АдресРезультата);
	Если РезультатПоиска = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ИмяСтрокиПоиска = ИмяСтрокиПоискаПоИдентификаторуЗадания(Форма, ИдентификаторЗадания);
	
	Если ИмяСтрокиПоиска = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ИмяСписка = ИмяРеквизитаСпискаПолей(ИмяСтрокиПоиска);
	ДеревоПолей = Форма[ИмяСписка];
	СтрокаРезультатовПоиска = КонструкторФормулКлиентСервер.СтрокаРезультатовПоиска(ДеревоПолей);
	
	НайденныеЭлементы = РезультатПоиска.НайденныеЭлементы;
	Для Каждого НайденныйЭлемент Из НайденныеЭлементы Цикл
		ДобавляемыйЭлемент = ДобавитьНайденнуюСтроку(СтрокаРезультатовПоиска, НайденныйЭлемент);
		ЗаполнитьЗначенияСвойств(ДобавляемыйЭлемент, НайденныйЭлемент);
		ДобавляемыйЭлемент.СоответствуетОтбору = Истина;
	КонецЦикла;
	КонструкторФормулКлиентСервер.СортироватьПоКолонке(СтрокаРезультатовПоиска, "Вес");
	УстановитьТекущуюСтрокуНаПервуюНайденную(Форма.Элементы[ИмяСписка], ДеревоПолей);
	Форма.Элементы[ИмяСписка + "Представление"].Видимость = Ложь;
	Форма.Элементы[ИмяСписка + "ПредставлениеПутиКДанным"].Видимость = Истина;
	
КонецПроцедуры

Функция ДобавитьНайденнуюСтроку(СтрокаРезультатовПоиска, НайденныйЭлемент)
	ЭлементыСтроки = СтрокаРезультатовПоиска.ПолучитьЭлементы();
	СтрокаДобавления = Неопределено;
	Для Каждого Элемент Из ЭлементыСтроки Цикл
		Если Элемент.ПутьКДанным = НайденныйЭлемент.ПутьКДанным Тогда
			СтрокаДобавления = Элемент;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Если СтрокаДобавления = Неопределено Тогда
		СтрокаДобавления = ЭлементыСтроки.Добавить();
	КонецЕсли;
	
	Возврат СтрокаДобавления;
КонецФункции

Функция ИмяСтрокиПоискаПоИдентификаторуЗадания(Форма, ИдентификаторЗадания)
	СоответствиеЗаданий = ПолучитьИзВременногоХранилища(Форма.АдресОписанияДлительнойОперации);
	Для Каждого Задание Из СоответствиеЗаданий Цикл
		Если Задание.Значение = ИдентификаторЗадания Тогда
			Возврат Задание.Ключ;
		КонецЕсли;
	КонецЦикла;
КонецФункции

Процедура УстановитьПредварительныйОтбор(Список, Отбор, СтрокаРезультатовПоиска)
	
	Если Отбор = "" Тогда
		Возврат;
	КонецЕсли;
	
	СтрокиОтбора = СтрРазделить(Отбор, ".");
	ИскатьВложенныеПоля = СтрокиОтбора.Количество() > 1;
	
	ПоискПоРезультатамПоиска = Список = СтрокаРезультатовПоиска И Не ИскатьВложенныеПоля;
	
	Для Каждого Элемент Из Список.ПолучитьЭлементы() Цикл
		Если ЗначениеЗаполнено(Элемент.ПредставлениеПутиКДанным) Тогда
			СтрокаОтбора = СтрокиОтбора[0];
			РезультатПоиска = НайтиТекстВСтроке(Элемент, СтрокаОтбора, ИскатьВложенныеПоля);
			
			Если РезультатПоиска.СоответствуетОтбору И Не ИскатьВложенныеПоля Тогда
				
				Если ПоискПоРезультатамПоиска Тогда
					НовыйЭлемент = Элемент;
				Иначе
					НовыйЭлемент = ДобавитьНайденнуюСтроку(СтрокаРезультатовПоиска, Элемент);
					ЗаполнитьЗначенияСвойств(НовыйЭлемент, Элемент);
				КонецЕсли;
				НовыйЭлемент.СоответствуетОтбору = РезультатПоиска.СоответствуетОтбору;
				НовыйЭлемент.Вес = РезультатПоиска.Вес;
				НовыйЭлемент.ПредставлениеПутиКДанным = РезультатПоиска.ФорматированнаяСтрока;
			ИначеЕсли ПоискПоРезультатамПоиска Тогда
				Элемент.СоответствуетОтбору = РезультатПоиска.СоответствуетОтбору;
				Элемент.Вес = РезультатПоиска.Вес;
			КонецЕсли;
			
			Если Не ПоискПоРезультатамПоиска И Элемент <> СтрокаРезультатовПоиска Тогда
				Если ИскатьВложенныеПоля Тогда
					УстановитьПредварительныйОтбор(Элемент, Сред(Отбор, СтрДлина(СтрокиОтбора[0])+2), СтрокаРезультатовПоиска);
				ИначеЕсли Не РезультатПоиска.СоответствуетОтбору Тогда
					УстановитьПредварительныйОтбор(Элемент, Отбор, СтрокаРезультатовПоиска);
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

Процедура СброситьРезультатыПоиска(Список)
	СброситьОтбор(Список);
	
	СтрокаРезультатовПоиска = КонструкторФормулКлиентСервер.СтрокаРезультатовПоиска(Список, Ложь);
	Если СтрокаРезультатовПоиска <> Неопределено Тогда
		ЭлементыСписка = Список.ПолучитьЭлементы();
		ЭлементыСписка.Удалить(ЭлементыСписка.Индекс(СтрокаРезультатовПоиска));
	КонецЕсли;
	
КонецПроцедуры

Процедура СброситьОтбор(Список)
	Для Каждого Элемент Из Список.ПолучитьЭлементы() Цикл
		Элемент.СоответствуетОтбору = Ложь;
		Элемент.ПодчиненныйЭлементСоответствуетОтбору = Ложь;
		Элемент.ПредставлениеПутиКДанным = Строка(Элемент.ПредставлениеПутиКДанным);
		СброситьОтбор(Элемент);
	КонецЦикла;
КонецПроцедуры

Процедура ДобавитьСтрокуОжидания(Список, СообщениеСтрокиОжидания)
	СтрокаОжиданияВыведена = Ложь;
	Строки = Список.ПолучитьЭлементы();
	Для Каждого Элемент Из Строки Цикл
		Если Элемент.Заголовок = СообщениеСтрокиОжидания Тогда
			СтрокаОжиданияВыведена = Истина;
			Прервать;
		КонецЕсли;
	КонецЦикла;	
	
	Если Не СтрокаОжиданияВыведена Тогда
		Элемент = Строки.Добавить();
		Элемент.Заголовок = СообщениеСтрокиОжидания;
		Элемент.ПредставлениеПутиКДанным = СообщениеСтрокиОжидания;
	КонецЕсли;
	
	Элемент.СоответствуетОтбору = Истина;
КонецПроцедуры

Процедура УдалитьСтрокуОжидания(Список, СообщениеСтрокиОжидания)
	СтрокаОжидания = Неопределено;
	Строки = Список.ПолучитьЭлементы();
	Для Каждого Элемент Из Строки Цикл
		Если Элемент.Заголовок = СообщениеСтрокиОжидания Тогда
			СтрокаОжидания = Элемент;
			Прервать;
		КонецЕсли;
	КонецЦикла;	
	
	Если СтрокаОжидания <> Неопределено Тогда
		Строки.Удалить(СтрокаОжидания);
	КонецЕсли;
КонецПроцедуры

Функция УстановитьТекущуюСтрокуНаПервуюНайденную(ТаблицаНаФорме, ДеревоПолей)
	Для Каждого Элемент Из ДеревоПолей.ПолучитьЭлементы() Цикл
		Если Элемент.СоответствуетОтбору Тогда
			ТаблицаНаФорме.ТекущаяСтрока = Элемент.ПолучитьИдентификатор();
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	
	Для Каждого Элемент Из ДеревоПолей.ПолучитьЭлементы() Цикл
		Если УстановитьТекущуюСтрокуНаПервуюНайденную(ТаблицаНаФорме, Элемент) Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Ложь;
КонецФункции

Функция НайтиТекстВСтроке(Строка, Текст, ПоискСУчетомУровней)
	
	Возврат КонструкторФормулКлиентСервер.НайтиТекстВСтроке(Строка, Текст,
		ОбщегоНазначенияКлиент.ШрифтСтиля("ВажнаяНадписьШрифт"), ОбщегоНазначенияКлиент.ЦветСтиля("РезультатУспехЦвет"), ПоискСУчетомУровней);
		
КонецФункции

// Конструктор дополнительных параметров для универсальных обработчиков конструктора формул.
// 
// Возвращаемое значение:
//  Структура:
//   * ВыполнитьНаСервере - Булево - выполнить запуск серверного универсального обработчика.
//   * КлючОперации - Строка 
//
Функция ПараметрыОбработчика()
	Параметры = Новый Структура;
	Параметры.Вставить("ВыполнитьНаСервере", Ложь);
	Параметры.Вставить("КлючОперации");
	Возврат Параметры;
КонецФункции

#КонецОбласти
