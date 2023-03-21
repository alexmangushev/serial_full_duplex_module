# Модуль полнодуплексного последовательного обмена

## Структура репозитория

* [modules](https://github.com/alexmangushev/serial_full_duplex_module/tree/master/modules) - описание модулей
* [testbenches](https://github.com/alexmangushev/serial_full_duplex_module/tree/master/testbenches) - тестбенчи
* [TOP](https://github.com/alexmangushev/serial_full_duplex_module/blob/master/modules/TOP.v) - главный файл проекта
* [test_TOP](https://github.com/alexmangushev/serial_full_duplex_module/blob/master/testbenches/test_TOP.v) - тестбенч для главного файла

При разработке быле решено выделить алгоритмы приема и передачи в отдельные 
модули([tx_fsm](https://github.com/alexmangushev/serial_full_duplex_module/blob/master/modules/tx_fsm.v) 
и [rx_fsm](https://github.com/alexmangushev/serial_full_duplex_module/blob/master/modules/rx_fsm.v)), которые объеденины в модуле верхнего уровня. 
Для модулей [tx_fsm](https://github.com/alexmangushev/serial_full_duplex_module/blob/master/modules/tx_fsm.v)
и [rx_fsm](https://github.com/alexmangushev/serial_full_duplex_module/blob/master/modules/rx_fsm.v) 
составлены собственные тесты ([test_tx_fsm](https://github.com/alexmangushev/serial_full_duplex_module/blob/master/testbenches/test_tx_fsm.v)
и [test_rx_fsm](https://github.com/alexmangushev/serial_full_duplex_module/blob/master/testbenches/test_rx_fsm.v).

Для запуска проекта необходимо открыть файл проекта (.qpf) с помощью среды разработки Quartus.

Разработка проекта велась в среде Quartus II 13.1 Web Edition. Запуск тестбенчей производился с помощью ModelSim_Altera.
Проект настроен на взаимодействие именно с этим симулятором. Перед проверкой модуля выбираем соответствующий тестбенч в настройках проекта.

Все тестбенчи пишут в консоль результат тестирования и информируют об ошибках, связанных с неверным результатом передачи/приема, 
а также с неправильными таймингами на заданных выходах. 

В ходе разработки модулей была применена параметризация, 
позволяющая без особых вмешательств в код изменить размерность передаваемых данных.