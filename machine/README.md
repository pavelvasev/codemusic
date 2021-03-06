# machine

Интерпретирует указанное объектное дерево согласно правилам,
предварительно добавленным в машину.

Совместимо с (parser)[../parser].

# Методы

## add_code( id, cod )
Добавляет код в машину.

 * **id** - идентификатор кода, символ руби
 * **cod** - код, lambda { |ctx| ... }

## add_cond( condition, codehash, options )

Добавляет в машину запись о расширении цепочки вычисления.

 * **condition** условие
 * **codehash** код, который следует вызвать при срабатывании условия
 * **options** дополнительные опции. Сейчас можно указать :prepend=>true, что будет означать "прикрепить слева".
 
Варианты условий
 * :someid - встреча узла :someid
 * [:someid, :attr1, :attr2, ..] - встреча узла :someid и наличие в нем аттрибутов :attr1, :attr2

## compute( request, data, comment )

Производит вычисление.

* **request** - дерево вычисления
* **data** - входные данные
* **comment*** некий комментарий

# Код
Функции cod могут использовать ctx - текущий контекст вычислений. Он имеет методы:

* ctx.r - результат вычисления
* ctx.machine - ссылка на машину
* ctx.input - входные данные (массив аргументов)
* ctx.request - объект, с которым произошел запрос. Можно почитать аттрибуты, например.
