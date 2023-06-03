# Витрина RFM

## 1.1. Выясните требования к целевой витрине.

	Присвойте каждому клиенту три значения — значение фактора Recency, значение фактора Frequency и значение фактора Monetary Value:
	- Фактор Recency измеряется по последнему заказу. Распределите клиентов по шкале от одного до пяти, где значение 1 получат те, кто либо вообще не делал заказов, либо делал их очень давно, а 5 — те, кто заказывал относительно недавно.
	- Фактор Frequency оценивается по количеству заказов. Распределите клиентов по шкале от одного до пяти, где значение 1 получат клиенты с наименьшим количеством заказов, а 5 — с наибольшим.
	- Фактор Monetary Value оценивается по потраченной сумме. Распределите клиентов по шкале от одного до пяти, где значение 1 получат клиенты с наименьшей суммой, а 5 — с наибольшей.

**Необходимые проверки и условия:**
- Проверьте, что количество клиентов в каждом сегменте одинаково. Например, если в базе всего 100 клиентов, то 20 клиентов должны получить значение 1, ещё 20 — значение 2 и т. д.
- Для анализа нужно отобрать только успешно выполненные заказы - заказ со статусом Closed.
- Просят при расчете витрины обращаться только к объектам из схемы analysis. Чтобы не дублировать данные (данные находятся в этой же базе), решаем создать view. Таким образом, View будут находиться в схеме analysis и вычитывать данные из схемы production. 

**Где хранятся данные:** в схеме production содержатся оперативные таблицы.

**Куда надо сохранить витрину:** витрина должна располагаться в той же базе в схеме analysis.

**Стуктура витрины:** витрина должна называться dm_rfm_segments и состоять из таких полей:
	- user_id
	- recency (число от 1 до 5)
	- frequency (число от 1 до 5)
	- monetary_value (число от 1 до 5)
**Глубина данных:** в витрине нужны данные с начала 2022 года.

**Обновления не нужны.**



## 1.2. Изучите структуру исходных данных.

Данные будут браться из схемы production, следующих таблиц и соответствующих столбцов:
- Таблица users. Используемые поля: id(тип int) - идентификатор пользователя.
- Таблица orderstatuses. Используемые поля: id(тип int) - идентификатор статуса заказа, key(тип varchar(255)) - значение ключа статуса.
- Таблица orders. Используемые поля: user_id(тип int) - идентификатор пользоавтеля, order_ts(тип timestamp) - дата и время заказа, payment(numeric(19,5)) - сумма оплаты по заказу.


## 1.3. Проанализируйте качество данных

Особых нареканий по по данным нет. Качество данных в источнике высокое, во всех таблицах в ddl стоят ограничения и проверки на NULL, указаны нужные ключи.  

## Найденные инструменты качества данных в источнике.

**Схема production**

| Таблицы       | Объект                                                                                           | Инструмент     | Для чего используется                                                    |
| ------------- | ------------------------------------------------------------------------------------------------ | -------------- | ------------------------------------------------------------------------ |
| users         | id int4 NOT NULL PRIMARY KEY                                                                     | Первичный ключ | Обеспечивает уникальность записей о пользователях                        |
| orders        | order_id int NOT NULL PRIMARY KEY                                                                | Первичный ключ | Обеспечивает уникальность записей о заказах                              |
| orders        | cost NOT NULL DEFAULT 0 CHECK ((cost = (payment + bonus_payment)))                               | Ограничение    | Обеспечивает корректность поля cost                                      |
| orders        | Все поля NOT NULL, связанные со стоимостью заказа DEFAULT 0                                      | Ограничение    | Финансовая информация не может быть 0                                    |
| orderstatuses | id int NOT NULL                                                                                  | Первичный ключ | Обеспечивает уникальность записей о статусах                             |
| orderstatuses | "key" varchar NOT NULL                                                                           | Ограничение    | Описание статуса не может быть NULL                                      |
| orderitems    | id int4 NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY                                        | Первичный ключ | Обеспечивает уникальность записей в таблице                              |
| orderitems    | FOREIGN KEY (order_id) REFERENCES production.orders(order_id)                                    | Внешний ключ   | В поле order_id могут быть записи только которые существуют в orders     |
| orderitems    | FOREIGN KEY (product_id) REFERENCES production.products(id)                                      | Внешний ключ   | В поле product_id могут быть записи только которые существуют в products |
| orderitems    | discount numeric NOT NULL DEFAULT 0 CHECK (((discount >= (0)::numeric) AND (discount <= price))) | Ограничение    | Корректность значения информации о скидке                                |
| orderitems    | UNIQUE (order_id, product_id)                                                                    | Ограничение    | Уникальность сочетания order_id + product_id                             |
| orderitems    | price numeric NOT NULL DEFAULT 0 CHECK ((price >= (0)::numeric))                                 | Ограничение    | price не может быть NULL                                                 |
| orderitems    | quantity int4 NOT NULL CHECK ((quantity > 0))                                                    | Ограничение    | Чтобы кол-во не могло быть NULL или <= 0                                 |
| products      | id int NOT NULL PRIMARY KEY                                                                      | Первичный ключ | Обеспечивает уникальность записей о пользователях                        |
| products      | price numeric NOT NULL DEFAULT 0 CHECK ((price >= (0)::numeric))                                 | Ограничение    | Цена не может быть NULL                                                  |



## 1.4. Подготовьте витрину данных

{См. задание на платформе}
### 1.4.1. Сделайте VIEW для таблиц из базы production.**

{См. задание на платформе}
```SQL
create or replace view analysis.orderitems as select * from production.orderitems;
create or replace view analysis.orderstatuses as select * from production.orderstatuses;
create or replace view analysis.orderstatuslog as select * from production.orderstatuslog;
create or replace view analysis.products as select * from production.products;
create or replace view analysis.users as select * from production.users;
create or replace view analysis.orders as select * from production.orders;

```

### 1.4.2. Напишите DDL-запрос для создания витрины.**

{См. задание на платформе}
```SQL
DROP TABLE IF EXISTS analysis.dm_rfm_segments;
create table analysis.dm_rfm_segments (
	user_id int NOT NULL PRIMARY KEY,
    recency int NOT NULL CHECK(recency >= 1 AND recency <= 5),
	frequency int NOT NULL CHECK(frequency >= 1 AND frequency <= 5),
	monetary_value int NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);


```

### 1.4.3. Напишите SQL запрос для заполнения витрины

{См. задание на платформе}
```SQL
truncate analysis.dm_rfm_segments;
insert into analysis.dm_rfm_segments(user_id,recency,frequency,monetary_value)
select u.id as "user_id", 
r.recency, 
f.frequency, 
m.monetary_value from 
	analysis.tmp_rfm_frequency as f, 
	analysis.tmp_rfm_recency as r, 
	analysis.tmp_rfm_monetary_value as m, 
	analysis.users as u
where u.id = r.user_id and u.id=m.user_id and u.id=f.user_id;
--
-- user_id recency frequency monetary_value
-- 0	1	2	3
-- 1	4	2	3
-- 2	2	2	4
-- 3	2	2	3
-- 4	4	2	2
-- 5	5	3	4
-- 6	1	2	4
-- 7	4	2	2
-- 8	1	1	2
-- 9	1	2	2


```



