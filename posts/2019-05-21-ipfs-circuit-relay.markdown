---
title: "Разбираемся с IPFS Circuit Relay"
description: Введение в технологию IPFS Circuit Relay.
tags: ipfs
---

Уже несколько лет я наблюдаю за проектом [IPFS](https://ipfs.io/) и радуюсь его интенсивному развитию. Наверно приятнее всего, что проект не ушел полностью в разработку [Filecoin](https://filecoin.io/) получив хорошее финансирование. Protocol Labs даже отделили сетевой стек от IPFS, обобщили и назвали его [libp2p](https://libp2p.io/), ни больше ни меньше библиотека для пиринговой коммуникации. Функциональность у libp2p довольно обширная, но в этой статье я бы хотел рассказать о наиболее интересной для меня, как для фаната mesh-сетей, особенности. Этот модуль вошел в спецификацию под именем [relay](https://github.com/libp2p/specs/tree/master/relay).

Внимательный пользователь IPFS мог заметить, что в выводе команды `ipfs swarm peers` все чаще стали появляться записи вида:

    /ipfs/QmRdjvsyoNjA2ZfAQBtQ7A2m5NmtSXLgxE55Brn1AUjZ1v/p2p-circuit/ipfs/QmZYoCxLeBYxPNcCEVp75HZBsZnfZELiECD1NHywL9F583
    /ipfs/QmRdjvsyoNjA2ZfAQBtQ7A2m5NmtSXLgxE55Brn1AUjZ1v/p2p-circuit/ipfs/QmUyHkuB7uMJWZnMSCvruKwH8UKTb8wsYmSWARRi17NXtF
    /ipfs/QmRdjvsyoNjA2ZfAQBtQ7A2m5NmtSXLgxE55Brn1AUjZ1v/p2p-circuit/ipfs/QmXbaSzhgnYfMo5xHd5s2K9GAXYYe9e1AEL4cTmrAmfikD
    /ipfs/QmRdjvsyoNjA2ZfAQBtQ7A2m5NmtSXLgxE55Brn1AUjZ1v/p2p-circuit/ipfs/QmWiXo5hhiABTaNGLFwA4H4jDFHHassY78vtrfD7FWe9SM
    /ipfs/QmRdjvsyoNjA2ZfAQBtQ7A2m5NmtSXLgxE55Brn1AUjZ1v/p2p-circuit/ipfs/Qmf6toae9WsQimsGypgz28SsoreG7Qd71WGdYSYuzQzHiN
    /ipfs/QmRdjvsyoNjA2ZfAQBtQ7A2m5NmtSXLgxE55Brn1AUjZ1v/p2p-circuit/ipfs/Qmb8kGDjik1fDmQB2V9TpXyJKB7ZyWD6xLjeue4rUoDdPE
    /ipfs/QmRdjvsyoNjA2ZfAQBtQ7A2m5NmtSXLgxE55Brn1AUjZ1v/p2p-circuit/ipfs/QmXVPXQMDSTUxy4kXTaNG7mUEuNZ3EzC5kz7Tv2c5am5Dz
    /ipfs/QmRdjvsyoNjA2ZfAQBtQ7A2m5NmtSXLgxE55Brn1AUjZ1v/p2p-circuit/ipfs/QmTryiBCgpQ5WzYUP6g5T8ZSo5esQK3cDbZDk1CG6QDFab
    /ipfs/QmRdjvsyoNjA2ZfAQBtQ7A2m5NmtSXLgxE55Brn1AUjZ1v/p2p-circuit/ipfs/QmcLqwzKxAw5b1xZqhdEWC32RMkpqeQnKUPw3AYNJ7cbcU
    /ipfs/QmRdjvsyoNjA2ZfAQBtQ7A2m5NmtSXLgxE55Brn1AUjZ1v/p2p-circuit/ipfs/QmUkqDU6njUCs1uQwQcPqSJ6pQ4n1cceDsskUt5VsjDTvF
    /ipfs/QmRdjvsyoNjA2ZfAQBtQ7A2m5NmtSXLgxE55Brn1AUjZ1v/p2p-circuit/ipfs/QmXM1vgBBjggPHAAgcS7KLUfkfwpouz766ZaGKE8Wpm4Pi
    /ipfs/QmRdjvsyoNjA2ZfAQBtQ7A2m5NmtSXLgxE55Brn1AUjZ1v/p2p-circuit/ipfs/QmS2tD2ztSnoJEKA5EkrzefS24yPgDRWXtiasMJ759k8Em
    /ipfs/QmRdjvsyoNjA2ZfAQBtQ7A2m5NmtSXLgxE55Brn1AUjZ1v/p2p-circuit/ipfs/QmeTDuU562Q6DwTrFeE5nPn7MVAhPmiBqGRrodR8NuZiGA
    /ipfs/QmRdjvsyoNjA2ZfAQBtQ7A2m5NmtSXLgxE55Brn1AUjZ1v/p2p-circuit/ipfs/QmTpazgTQNwD1f3e3yMRqXB7BW9wzeJ3hGfiPqyJhjzWdf
    /ipfs/QmRdjvsyoNjA2ZfAQBtQ7A2m5NmtSXLgxE55Brn1AUjZ1v/p2p-circuit/ipfs/QmWiTQoWhJZDxikxHEbjmRiQT4FMgzZS98gfPNJ9GWWuZ8

Это довольно странные мульти-адреса так как в них нет традиционных для IP-сетей адреса и порта для связи с пиром, как например, здесь:

    /ip4/178.45.40.65/tcp/4001/ipfs/QmbtPSNsRQeecUavxVZTULaPhp7owBgfNdbNY5egVPn9jn

Спецификация утверждает, что это специальный формат адреса, который включает в процедуру соединения с пиром еще одну сторону - Релей.

    +-----+    /ip4/.../tcp/.../ws/p2p/QmRelay    +-------+    /ip4/.../tcp/.../p2p/QmTwo       +-----+
    |QmOne| <------------------------------------>|QmRelay|<----------------------------------->|QmTwo|
    +-----+   (/libp2p/relay/circuit multistream) +-------+ (/libp2p/relay/circuit multistream) +-----+
         ^                                         +-----+                                         ^
         |           /p2p-circuit/QmTwo            |     |                                         |
         +-----------------------------------------+     +-----------------------------------------+

Релей нужен, когда в топологии нашей сети присутствуют два узла (QmOne и QmTwo), прямое соединение между которыми невозможно (например, оба находятся за глухим NAT), а связь установить необходимо. В такой ситуации выбирается специальный узел-посредник, который проксирует соединение от одного узла другому и наоборот.

В relay-модуль так же [планируют добавить](https://github.com/libp2p/specs/tree/master/relay#future-work) множественное проксирование (multihop) и автоматический поиск релеев в сети.

Звучит здорово, посмотрим как это работает на практике. Попробуем разобрать Circuit Relay адрес:

    /ipfs/QmRdjvsyoNjA2ZfAQBtQ7A2m5NmtSXLgxE55Brn1AUjZ1v/p2p-circuit/ipfs/QmWiTQoWhJZDxikxHEbjmRiQT4FMgzZS98gfPNJ9GWWuZ8
    \__________________________________________________/            \__________________________________________________/
             Адрес ноды-посредника (Relay)                                            Адрес целевой ноды

Спецификация так же утверждает, что при подключении достаточно указываеть адрес целевой ноды в таком виде:

    /p2p-circuit/ipfs/QmWiTQoWhJZDxikxHEbjmRiQT4FMgzZS98gfPNJ9GWWuZ8

Я буду связываться через команду `ipfs ping` со своей домашней рабочей станцией. Рабочий ноутбук и домашняя станция находятся за NAT и не имеют прямого подключения. Для начала мне нужен идентификатор ноды на домашней станции, его получим командой `ipfs id`.

    $ ipfs id
    {
        "ID": "QmTYXdMQjzV3tPEphTRCYw4TQp72u3GnaBLCsfGGW3Aum8",
        ...
    }

Хорошо, теперь формируем мульти-адрес в Circuit Relay сети:

    /p2p-circuit/ipfs/QmTYXdMQjzV3tPEphTRCYw4TQp72u3GnaBLCsfGGW3Aum8

Наконец пробуем пингануть полученный адрес:

    $ ipfs ping /p2p-circuit/ipfs/QmTYXdMQjzV3tPEphTRCYw4TQp72u3GnaBLCsfGGW3Aum8 
    PING QmTYXdMQjzV3tPEphTRCYw4TQp72u3GnaBLCsfGGW3Aum8.
    Pong received: time=641.62 ms
    Pong received: time=639.79 ms
    Pong received: time=640.72 ms
    Pong received: time=572.90 ms
    Pong received: time=652.26 ms
    Pong received: time=571.97 ms

Поиск релея может занять время, у меня это заняло 15-20 секунд. Так или иначе коннект есть! Соединение через swarm работает так, будто оба узла находятся в одной IP-сети.

    $ ipfs swarm connect /p2p-circuit/ipfs/QmTYXdMQjzV3tPEphTRCYw4TQp72u3GnaBLCsfGGW3Aum8
    connect QmTYXdMQjzV3tPEphTRCYw4TQp72u3GnaBLCsfGGW3Aum8 success 

В итоге у нас получилось разобраться как выглядят адреса в Circuit Relay сети и подключиться к ноде не зная ее IP-адреса. Надеюсь читатель, воодушевившись потенциалом связности, который Circuit Relays привносят в IPFS, запустит еще пару нод на ПК, RaspberryPi или микроволновке. Присоединяйтесь к веселому и шумному Рою!
