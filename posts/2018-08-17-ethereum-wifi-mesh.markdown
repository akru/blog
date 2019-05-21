---
title: "Настраиваем Ethereum поверх WiFi-mesh"
description: Инструкция по настройке частной Ethereum-сети в WiFi-mesh.
tags: ethereum
---

> В продолжение цикла статей о Mesh-сетях попробуем развернуть приватную сеть Ethereum поверх WiFi-mesh. 

Установка
---------

1. WiFi-mesh сеть с IPv6-адресацией из [предыдущей статьи](2018-08-16-ipfs-wifi-mesh.html)
1. [GEth](https://geth.ethereum.org/downloads) 
1. [NodeJS/NPM](https://nodejs.org/en/download/package-manager/)

Настройка и запуск
------------------

Наша частная Ethereum сеть будет состоять из двух ноутбуков в одной mesh-сети.
Для начала подготовим genesis block, первый блок в цепочке.

```
{
   "config": {
      "chainId": 63,
      "homesteadBlock": 0,
      "eip155Block": 0,
      "eip158Block": 0,
      "byzantiumBlock": 0
   },
   "alloc": {},
   "difficulty": "400",
   "gasLimit": "16000000",
   "difficulty": "0x0400",
   "coinbase": "0x0000000000000000000000000000000000000000",
   "timestamp": "0x00",
   "nonce": "0x00006d6f7264656e",
   "mixHash": "0x00000000000000000000000000000000000000647572616c65787365646c6578",
   "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000"
}
```

### Первая нода

Инициализируем новую БД этим блоком.

```
$ mkdir robonomics2018
$ geth --datadir robonomics2018 --networkid 63 init robonomics2018_genesis.json
```

Затем запускаем ноду Ethereum в новой сети.

```
$ geth --datadir robonomics2018 --networkid 63 console
```

Создаем аккаунт, указывая в аргументах пароль.

```
> personal.newAccount('1')
```

Перезапускаем ноду в режиме майнера.

```
$ geth --datadir ./robonomics2018 --networkid 63 --mine --minerthreads 1
```

Обращаем внимание при старте на строчку вида

```
enode://8753ced723978dd965b68d482b57e46c3eee5c98974edeb6888b1796e74b4ffe22e7aaeeb61293a25ce0d8ce148fa81178414f785cd507f3e4ea417ddad5b3c5@[::]:30303
```

Сохраняем, она нам пригодится позднее.

### Вторая нода

Инициализация идентична первой, однако после создания аккаунта попробуем добавить первый узел, для получения с него цепочки блоков.

```
> admin.addPeer("enode://8753ced723978dd965b68d482b57e46c3eee5c98974edeb6888b1796e74b4ffe22e7aaeeb61293a25ce0d8ce148fa81178414f785cd507f3e4ea417ddad5b3c5@[fca2:d099:c448:8666:e3f1:f39e:aad0:ea07]:30303")
```

Здесь enode это идентификатор первого узла, сохраненный ранее, а IPv6 в квадратных скобках его адрес в сети cjdns.

Если все настроено правильно, сеть должна начать синхронизироваться без ошибок и мы можем перезапустить вторую ноду в режиме майнера.

Эксперимент
-----------

В качестве эксперимента развернем инфраструктуру умных контрактов в нашей частной Ethereum-сети.

Когда мы намайнили достаточное число ether, перезапустим geth с ключом `--rpc`.

```
$ geth --datadir ./robonomics2018 --networkid 63 --bootnodes "enode://8753ced723978dd965b68d482b57e46c3eee5c98974edeb6888b1796e74b4ffe22e7aaeeb61293a25ce0d8ce148fa81178414f785cd507f3e4ea417ddad5b3c5@[fca2:d099:c448:8666:e3f1:f39e:aad0:ea07]:30303" --rpc --mine --minerthreads 1
```

Разблокируем основной аккант для отправки транзакций.

```
> personal.unlockAccount(eth.accounts[0], '1', 0)
```

Скачаем репозиторий с умными контрактам и запустим миграцию.

```
$ git clone --recursive https://github.com/airalab/robonomics_contracts -b robonomics2018
$ cd robonomics_contracts
$ npm i
$ ./node_modules/truffle/build/cli.bundled.js migrate --network robonomics2018
```

Если все получилось, то в нашей приватной сети развернется инфраструктура умных контрактов сети Robonomics.

Заключение
----------

В этой статье мы настроили частную сеть Ethereum поверх WiFi-mesh и развернули тестовую инфраструктуру смарт-контрактов.

