///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

Функция ИдентификаторКоманды(Документ, Организация, Получатель) Экспорт
	
	ТипОбъекта = ОбщегоНазначения.ИдентификаторОбъектаМетаданных(ТипЗнч(Документ));
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ОсновныеПечатныеФормыКонтрагентов.Идентификатор
		|ИЗ
		|	РегистрСведений.ОсновныеПечатныеФормыКонтрагентов КАК ОсновныеПечатныеФормыКонтрагентов
		|ГДЕ
		|	ОсновныеПечатныеФормыКонтрагентов.Организация = &Организация
		|	И ОсновныеПечатныеФормыКонтрагентов.Получатель = &Получатель
		|	И ОсновныеПечатныеФормыКонтрагентов.ТипОбъекта = &ТипОбъекта
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ОсновныеПечатныеФормыКонтрагентов.Идентификатор
		|ИЗ
		|	РегистрСведений.ОсновныеПечатныеФормыКонтрагентов КАК ОсновныеПечатныеФормыКонтрагентов
		|ГДЕ
		|	ОсновныеПечатныеФормыКонтрагентов.Организация = &Организация
		|	И ОсновныеПечатныеФормыКонтрагентов.ТипОбъекта = &ТипОбъекта";
	
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("Получатель", Получатель);
	Запрос.УстановитьПараметр("ТипОбъекта", ТипОбъекта);
	
	УстановитьПривилегированныйРежим(Истина);
	РезультатЗапроса = Запрос.Выполнить();
	УстановитьПривилегированныйРежим(Ложь);
	Выборка = РезультатЗапроса.Выбрать();
	
	Если Выборка.Следующий() Тогда
		Результат = Выборка.Идентификатор;
	Иначе
		Результат = "";
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Процедура ЗаписатьИдентификаторПечатнойФормы(Ссылка, Идентификатор) Экспорт
	
	КлючевыеРеквизиты = КлючевыеРеквизиты();
	
	УправлениеПечатьюПереопределяемый.ПриОпределенииКлючевыхРеквизитовОсновныхПечатныхФорм(
		Ссылка, КлючевыеРеквизиты);
	
	Организация = КлючевыеРеквизиты.Организация;
	Получатель  = КлючевыеРеквизиты.Получатель;
	ТипОбъекта  = ОбщегоНазначения.ИдентификаторОбъектаМетаданных(Ссылка.Метаданные());
	
	НаборЗаписей = СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Организация.Установить(Организация);
	НаборЗаписей.Отбор.Получатель.Установить(Получатель);
	НаборЗаписей.Отбор.ТипОбъекта.Установить(ТипОбъекта);
	УстановитьПривилегированныйРежим(Истина);
	НаборЗаписей.Прочитать();
	УстановитьПривилегированныйРежим(Ложь);
	
	ИдентификаторБезСпецСимволов = УправлениеПечатьюКлиентСервер.ИдентификаторБезСпецСимволов(Идентификатор);
	
	Если НаборЗаписей.Количество() = 1 Тогда
		Если НаборЗаписей[0].Идентификатор = ИдентификаторБезСпецСимволов Тогда
			Возврат;
		Иначе
			НаборЗаписей[0].Идентификатор = ИдентификаторБезСпецСимволов;
		КонецЕсли;
	Иначе
		НаборЗаписей.Добавить();
		НаборЗаписей[0].Организация   = Организация;
		НаборЗаписей[0].Получатель    = Получатель;
		НаборЗаписей[0].ТипОбъекта    = ТипОбъекта;
		НаборЗаписей[0].Идентификатор = ИдентификаторБезСпецСимволов;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	НаборЗаписей.Записать();
	УстановитьПривилегированныйРежим(Ложь);
КонецПроцедуры

Функция КлючевыеРеквизиты() Экспорт
	
	Структура = Новый Структура;
	Структура.Вставить("Организация", Неопределено);
	Структура.Вставить("Получатель", Неопределено);
	
	Возврат Структура;
	
КонецФункции

#КонецОбласти

#КонецЕсли
