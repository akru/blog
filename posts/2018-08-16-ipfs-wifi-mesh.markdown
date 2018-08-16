---
title: Настраиваем IPFS поверх WiFi-mesh
---

> В этой статье мы рассмотрим как настроить WiFi mesh сеть на нескольких ноутбуках и обмениваться в ней файлами через IPFS.

Установка
---------

1. [B.A.T.M.A.N. adv](https://packages.debian.org/sid/batctl)
1. [cjdns](https://github.com/cjdelisle/cjdns/blob/master/README_RU.md#%D0%9A%D0%B0%D0%BA-%D1%83%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%B8%D1%82%D1%8C-cjdns)
1. [IPFS](https://ipfs.io/docs/install/)

Настройка и запуск
------------------

1. [B.A.T.M.A.N adv](https://www.open-mesh.org/projects/batman-adv/wiki/Quick-start-guide#Simple-mesh-network) (SSID: fftlt-ibss)
1. [cjdns](https://github.com/cjdelisle/cjdns/blob/master/README_RU.md#%D0%A3%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B0) (п.2-3 можно пропустить)
1. `ipfs init && ipfs daemon --enable-pubsub-experiment`

Эксперимент
-----------

### WiFi (L2)

```
# iwconfig wlan1 mode ad-hoc
# iwconfig wlan1 essid fftlt-ibss
# iwconfig wlan1 ap 62:C2:3A:86:A6:EE
# iwconfig wlan1 channel 3
# batctl if add wlan1
# ifconfig wlan1 up
```

Если WiFi-mesh запущен и работает правильно, то у mesh-ноды должны появиться соседи:

```
# batctl n
[B.A.T.M.A.N. adv 2018.2, MainIF/MAC: wlan1/50:3e:aa:4b:a6:4f (bat0/fa:48:cd:c0:f4:65 BATMAN_IV)]                                      
IF             Neighbor              last-seen
        wlan1     42:c1:a1:9e:d1:82    2.454s
        wlan1     ea:1d:45:49:08:92    4.906s
        wlan1     26:58:bd:72:d8:3a   10.258s  
```

### cjdns (L3)

```
# ./cjdroute --genconf >> cjdroute.conf
# ./cjdroute < cjdroute.conf
```

Если cjdns запущен и работает правильно, то в сети демон сможет найти соседей:

```
# git clone https://github.com/cjdelisle/cjdns && cd cjdns
# ./tools/peerStats 
00:e0:4c:36:04:d0 v20.0000.0000.0000.001d.43pvwhgxxcnw97f3rj9ymd621vjkrcwrr4b9h5jp68u78tjcvsv0.k ESTABLISHED in 4kb/s out 1kb/s  LOS 6 "outer"
c4:85:08:9f:c0:e0 v20.0000.0000.0000.001b.xg1bumyc2ycxysg621701uhrj1csztshvy1t4840hqnxtlwcrtj0.k ESTABLISHED in 0kb/s out 0kb/s "outer"
b0:52:16:7a:3b:87 v20.0000.0000.0000.0019.6bjqsurq6t6w8vgts0v6rvs6pgn6w22w6vskkz8gj7fmugph21k0.k ESTABLISHED in 6kb/s out 0kb/s  LOS 6 "outer"
d4:5d:df:13:67:62 v20.0000.0000.0000.0017.sg7hq3rmjvxumftly0f7j0m2hrbbll90xbthhz1hnkgnklg31rv0.k ESTABLISHED in 1kb/s out 1kb/s  LOS 6 "outer"
94:c6:91:10:38:c4 v20.0000.0000.0000.0015.8lrdctgmz58jqb37pss1b34dbpnzv2sknlbn6qbwfpfsbvpjb6h0.k ESTABLISHED in 0kb/s out 0kb/s  LOS 6 "outer"
164.132.111.49:53741 v20.0000.0000.0000.0013.35mdjzlxmsnuhc30ny4rhjyu5r1wdvhb09dctd1q5dcbq6r40qs0.k ESTABLISHED in 22kb/s out 18kb/s  LOS 103 "outer"                                                                                                                          
9c:b6:d0:1e:c0:43 v20.0000.0000.0000.009e.plqfw2mnn6h2p71fhk7d3y7gk3cblq1u1pkk9374mvdw0f2y7hc0.k ESTABLISHED in 0kb/s out 0kb/s  LOS 6 "outer"
b8:27:eb:f2:de:ad v20.0000.0000.0000.001f.6w62jcwcg1qvcz0lvlzzxrdmx5nz3n94dst9xvpvnfr6gzcjlq10.k ESTABLISHED in 0kb/s out 0kb/s  LOS 6 "outer"
```

Свой адрес в сети cjdns можно узнать командой

```
$ ip a show tun0                                                                                                         
6: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1304 qdisc pfifo_fast state UNKNOWN group default qlen 500                      
    link/none 
    inet6 fcd1:5580:c813:6277:4af2:23f1:5229:e20f/8 scope global 
       valid_lft forever preferred_lft forever
    inet6 fe80::b4e5:d39d:8eb6:6cf5/64 scope link stable-privacy 
       valid_lft forever preferred_lft forever
```

### IPFS (L4+)

```
# ipfs daemon --enable-pubsub-experiment
```

Для работы IPFS сети нам потребуется установить соединение хотя бы с одной нодой:

```
# ipfs swarm connect '/ip6/fc77:92e6:fdc4:801a:97f5:52c3:b2db:a86c/tcp/4001/ipfs/QmcYyqnn3vwgkYiDKAEYJK5gdvDmeqFojEVRuArCXWaaaT'
success
```

Здесь мы используем cjdns-адрес новы в локальной сети и ее IPFS-идентификатор:

```
# ipfs id
{
        "ID": "QmbtPSNsRQeecUavxVZTULaPhp7owBgfNdbNY5egVPn9jn",
        "PublicKey": "CAASpgIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC2TfH5eJhFCA/YGogPkHdHrBh6II9PAn2R6wRSibngbbFU+22FEfHepqbQjRvqcygqdiNy7bCkgua9haWDwdrYircRkgj/vykKBDqQ1uDIq2cp56IubVzRO1plDrhtMEXbFXK/flvlmbWge6cjRNeAkvTZBxDmYaqG8EV1gb/Sqwj4yvNobheFBQSiDMYiddVfoJKLwd5aMCzVe3yzbkbWr9WD34vm2OWbuAuuVhex7kUe4bUaSstxJWOfmDPG9dR80F3UT/NUc7ZInXMY38DJeasem+Y1h99RSiAtuDE8g/IhkZoZEG7FUKZjIvH9C/BXkjlIvUXrCBqY8ULO3l3lAgMBAAE=",
        "Addresses": [
                "/ip4/127.0.0.1/tcp/4001/ipfs/QmbtPSNsRQeecUavxVZTULaPhp7owBgfNdbNY5egVPn9jn",
                "/ip4/192.168.88.34/tcp/4001/ipfs/QmbtPSNsRQeecUavxVZTULaPhp7owBgfNdbNY5egVPn9jn",
                "/ip4/192.168.56.1/tcp/4001/ipfs/QmbtPSNsRQeecUavxVZTULaPhp7owBgfNdbNY5egVPn9jn",
                "/ip4/169.254.1.66/tcp/4001/ipfs/QmbtPSNsRQeecUavxVZTULaPhp7owBgfNdbNY5egVPn9jn",
                "/ip4/172.17.0.1/tcp/4001/ipfs/QmbtPSNsRQeecUavxVZTULaPhp7owBgfNdbNY5egVPn9jn",
                "/ip4/169.254.16.151/tcp/4001/ipfs/QmbtPSNsRQeecUavxVZTULaPhp7owBgfNdbNY5egVPn9jn",
                "/ip6/::1/tcp/4001/ipfs/QmbtPSNsRQeecUavxVZTULaPhp7owBgfNdbNY5egVPn9jn",
                "/ip6/fcd1:5580:c813:6277:4af2:23f1:5229:e20f/tcp/4001/ipfs/QmbtPSNsRQeecUavxVZTULaPhp7owBgfNdbNY5egVPn9jn",
                "/ip4/178.163.67.5/tcp/48565/ipfs/QmbtPSNsRQeecUavxVZTULaPhp7owBgfNdbNY5egVPn9jn",
                "/ip6/fcd1:5580:c813:6277:4af2:23f1:5229:e20f/tcp/4001/ipfs/QmbtPSNsRQeecUavxVZTULaPhp7owBgfNdbNY5egVPn9jn"
        ],
        "AgentVersion": "go-ipfs/0.4.17/",
        "ProtocolVersion": "ipfs/0.1.0"
}
```

#### IPFS PubSub

Для работы Publisher/Subscriber в IPFS достаточно запустить демон с флагом `--enable-pubsub-experiment`.

Протестируем работу на локальной ноде, запускаем в одном окне подписку на топик:

```
# ipfs pubsub sub --discover my-ipfs-topic
```

В другом окне публикуем сообщение:

```
# ipfs pubsub pub my-ipfs-topic "Hello world"
```

#### Передача файлов

Файлы в IPFS lобавляются командой `ipfs add`, после этого происходит сохранение файла в локальном хранилище, команда возвращает IPFS-хеш.

```
# echo "Hello world" | ipfs add                                                                                          
added QmePw8gVcBMb8x6kAep6aMBAX23hCSk6iZW3i9VKkiFhu1 QmePw8gVcBMb8x6kAep6aMBAX23hCSk6iZW3i9VKkiFhu1                                    
 12 B / ? [---------------------------------------------------------------------------------------------------------------=-----------] 
```

Получаем файл командой `ipfs get`:

```
# ipfs get QmePw8gVcBMb8x6kAep6aMBAX23hCSk6iZW3i9VKkiFhu1                                                                
Saving file(s) to QmePw8gVcBMb8x6kAep6aMBAX23hCSk6iZW3i9VKkiFhu1                                                                       
 20 B / 20 B [==============================================================================================================] 100.00% 0s
```

Заключение
----------

В статье мы настроили пиринговую сеть на трех различных уровнях, задействовали эту инфраструктуру в практических целях для широковещательного обмена сообщениями в реальном веремени и передачи файлов.

