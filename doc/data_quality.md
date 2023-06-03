# Качество данных

## Оценка качества данные в источнике.

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
