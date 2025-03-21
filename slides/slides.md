---
marp: true
theme: gaia
_class: lead
paginate: true
backgroundColor: #fff
backgroundImage: url('https://marp.app/assets/hero-background.svg')
---

![bg left:40% 80%](./img/logo.png)

# **Nextcloud**

Slides voor de Nextcloud workshop van het IT-lab


---

![bg left:100% 60%](./img/logo_nextcloud_blue.svg) <!-- Plaats voor logo voor openingsslide, foefel gerust met de sizes van de bg -->

---


# Meevolgen op:

nextcloud-workshop.it-lab.be/slides <!-- URL naar de slides -->

![QR bg right contain](./img/link_qr.png) <!-- QR-code naar de slides -->

---

# Wat is Nextcloud?

- Jouw eigen private cloud
- Grafische interface om eenvoudig in te loggen en bestanden te beheren


---

# Waarom Nextcloud?

- Eigen beheer van data
- Transparantie en security
- Gebruiksvriendelijkheid!


---

# Demo - Docker

- Opzetten van een eigen Nextcloud instantie
- 

---

# Compose file (test omgeving!)


<style scoped>
code {
   font-family:  "Times New Roman", Times, serif;
   overflow-y: auto;
   max-height: 400px
}
</style>

```
services:
  db:
    container_name: 'mariadb'
    image: mariadb:10.6
    restart: always
    command: --transaction-isolation=READ-COMMITTED --log-bin=binlog --binlog-format=ROW
    volumes:
      - /home/vagrant/nextcloud/database:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=test
      - MYSQL_PASSWORD=test
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud

  app:
    container_name: nextcloud
    image: nextcloud:29.0.2
    restart: always
    ports:
      - 8080:80
    links:
      - db
    volumes:
      - /home/vagrant/nextcloud/nextcloud:/var/www/html
      # - /home/vagrant/nextcloud/apps:/var/www/html/custom_apps
      # - /home/vagrant/nextcloud/config:/var/www/html/config
      # - /home/vagrant/nextcloud/data:/var/www/html/data
      # - /home/vagrant/nextcloud/themes:/var/www/html/themes
    environment:
      - MYSQL_PASSWORD=test
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud
      - MYSQL_HOST=db
```

---