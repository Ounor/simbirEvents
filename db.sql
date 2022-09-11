CREATE SCHEMA simbirsoft;
--Таблицы
CREATE TABLE simbirsoft.city (
	id int4 NOT NULL,
	"name" text NOT NULL,
	CONSTRAINT city_name_key UNIQUE (name),
	CONSTRAINT city_pkey PRIMARY KEY (id)
);

CREATE TABLE simbirsoft.direction (
	id int4 NOT NULL,
	"name" text NOT NULL,
	CONSTRAINT direction_name_key UNIQUE (name),
	CONSTRAINT direction_pkey PRIMARY KEY (id)
);

CREATE TABLE simbirsoft.userlist (
	userid int4 NOT NULL,
	loginid text NULL,
	passworduser text NOT NULL,
	firstname text NOT NULL,
	lastname text NOT NULL,
	middlename text NULL,
	deleted int4 NULL,
	cityid int4 NULL,
	directionid int4 NULL,
	CONSTRAINT userlist_loginid_key UNIQUE (loginid),
	CONSTRAINT userlist_pkey PRIMARY KEY (userid),
	CONSTRAINT userlist_cityid_fkey FOREIGN KEY (cityid) REFERENCES simbirsoft.city(id),
	CONSTRAINT userlist_directionid_fkey FOREIGN KEY (directionid) REFERENCES simbirsoft.direction(id)
);

CREATE TABLE simbirsoft.events (
	id int4 NOT NULL DEFAULT,
	nameevent text NOT NULL,
	cityid int4 NULL,
	place text NULL,
	description text NULL,
	countpeople int4 NULL,
	directionid int4 NULL,
	image text NULL,
	organizerid int4 NULL,
	timeevent text NULL,
	dateevent timestamp NULL,
	CONSTRAINT events_pkey PRIMARY KEY (id),
	CONSTRAINT events_cityid_fkey FOREIGN KEY (cityid) REFERENCES simbirsoft.city(id),
	CONSTRAINT events_directionid_fkey FOREIGN KEY (directionid) REFERENCES simbirsoft.direction(id),
	CONSTRAINT events_organizerid_fkey FOREIGN KEY (organizerid) REFERENCES simbirsoft.userlist(userid)
);

CREATE TABLE simbirsoft.eventsusers (
	eventid int4 NOT NULL,
	userid int4 NOT NULL,
	organizer bool NULL,
	inqueue bool NULL,
	registrdate timestamp NULL,
	CONSTRAINT eventsusers_unique UNIQUE (eventid, userid),
	CONSTRAINT eventsusers_eventid_fkey FOREIGN KEY (eventid) REFERENCES simbirsoft.events(id),
	CONSTRAINT eventsusers_userid_fkey FOREIGN KEY (userid) REFERENCES simbirsoft.userlist(userid)
);

CREATE TABLE simbirsoft.favoriteevents (
	eventid int4 NOT NULL,
	userid int4 NOT NULL,
	CONSTRAINT favoriteevents_unique UNIQUE (eventid, userid),
	CONSTRAINT eventsusers_eventid_fkey FOREIGN KEY (eventid) REFERENCES simbirsoft.events(id),
	CONSTRAINT eventsusers_userid_fkey FOREIGN KEY (userid) REFERENCES simbirsoft.userlist(userid)
);

CREATE TABLE simbirsoft.feedback (
	userid int4 NULL,
	eventid int4 NULL,
	feedback text NULL,
	showfeedback bool NULL,
	rating int4 NULL,
	CONSTRAINT feedback_rating_check CHECK ((rating = ANY (ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]))),
	CONSTRAINT feedback_eventid_fkey FOREIGN KEY (eventid) REFERENCES simbirsoft.events(id),
	CONSTRAINT feedback_userid_fkey FOREIGN KEY (userid) REFERENCES simbirsoft.userlist(userid)
);

CREATE TABLE simbirsoft.chat (
	userid int4 NULL,
	eventid int4 NULL,
	dtime timestamp NULL,
	message text NULL,
	CONSTRAINT chat_eventid_fkey FOREIGN KEY (eventid) REFERENCES simbirsoft.events(id),
	CONSTRAINT chat_userid_fkey FOREIGN KEY (userid) REFERENCES simbirsoft.userlist(userid)
);

/*Последовательности*/
/*создание последовательности для таблицы "Города"*/
create sequence if not exists simbirsoft.city_sqnc increment 1 minvalue 1 no maxvalue start 1;
alter table simbirsoft.city
alter column id
set default nextval('simbirsoft.city_sqnc');
alter sequence simbirsoft.city_sqnc owned by simbirsoft.city.id;

/*создание последовательности для таблицы "Направления"*/
create sequence if not exists simbirsoft.direction_sqnc increment 1 minvalue 1 no maxvalue start 1;
alter table simbirsoft.direction
alter column id
set default nextval('simbirsoft.direction_sqnc');
alter sequence simbirsoft.direction_sqnc owned by simbirsoft.direction.id;

/*создание последовательности для таблицы "Пользователи"*/
create sequence if not exists simbirsoft.userlist_sqnc increment 1 minvalue 1 no maxvalue start 1;
alter table simbirsoft.userlist
alter column userid
set default nextval('simbirsoft.userlist_sqnc');
alter sequence simbirsoft.userlist_sqnc owned by simbirsoft.userlist.userid;

/*создание последовательности для таблицы "Мероприятия"*/
create sequence if not exists simbirsoft.events_sqnc increment 1 minvalue 1 no maxvalue start 1;
alter table simbirsoft.events
alter column id
set default nextval('simbirsoft.events_sqnc');
alter sequence simbirsoft.events_sqnc owned by simbirsoft.events.id;


/*Наполнение таблиц данными*/
insert into simbirsoft.direction(name) 
values 
('Backend'),
('Frontend'),
('QA'),
('Analytics'),
('RND'),
('Архитектурный комитет'),
('DevOps'),
('Design'),
('HR'),
('PM'),
('Юридическое направление'),
('Presale'),
('Сопровождение бизнес-процессов'),
('SDET'),
('Web'),
('TeamLeads'),
('Accounting'),
('Отдел продаж'),
('PR'),
('Финансовое направление');

insert into simbirsoft.city(name)
values('Ульяновск'),
('Казань'),
('Самара'),
('Саранск'),
('Краснодар'),
('Димитровград'),
('Удаленка');

insert into simbirsoft.userlist(loginid, passworduser, firstname, lastname, deleted, cityid, directionid)
values('a.moiseeva','123','Алёна','Моисеева',0, 1, 1),
('a.abrosimova',' 123', 'Антонина', 'Абросимова',0,1,2),
('a.zheltov', '123','Александр','Желтов',0,2,1),
('a.pereladov','123','Александр','Переладов',0,	8, 1),
('a.ivanov', '123', 'Сергей', 'Иванов', 0, 4, 2),
('a.lomov', '123', 'Михаил', 'Ломов', 0, 5, 7),
('a.lomova', '123',	'Ольга', 'Ломова', 0, 5, 4),
('a.andreeva', '123', 'Анна', 'Андреева', 0, 2, 3);

--Функции
CREATE OR REPLACE FUNCTION simbirsoft.addfavoriteevents(peventid integer, puserid integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
/*
 * Функция для добавления мероприятия в понравившиеся
 * 
 * Функция возвращает таблицу с полями:
 * peventid -идентификатор мероприятия
 * puserid - идентификатор пользователя
 */
declare 
begin  
 insert into simbirsoft.favoriteevents(eventid, userid)
 values(peventid, puserid);
 end;
$function$
;

CREATE OR REPLACE FUNCTION simbirsoft.addusertoevent(puserid integer, peventid integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
/*
 * Функция для записи пользователя на мероприятие
 * 
 * Входные параметры:
 * puserid - идентификатор пользователя
 * peventid - идентификатор мероприятия
 * 
 */
declare
 lcountpeople integer;
 lnumbofregistered integer; --количесвто записавшихся на мероприятие
 lnuminqueue integer;
begin
  select countpeople
  into lcountpeople
  from simbirsoft.events e
  where e.id = peventid;
 
  select count(*)
  into lnumbofregistered
  from simbirsoft.eventsusers e
  where e.eventid = peventid and e.inqueue = false and e.organizer = false;
  
  if lcountpeople is null or coalesce(lnumbofregistered,0) < lcountpeople then 
   insert into simbirsoft.eventsusers(userid, eventid, organizer, inqueue, registrdate) values(puserid, peventid, false, false, clock_timestamp());  
    raise notice '%', 'записали';
  else 
    raise notice '%', 'очередь';    
     insert into simbirsoft.eventsusers(userid, eventid, organizer, inqueue, registrdate) values(puserid, peventid, false, true, clock_timestamp());
  end if;
  
end;
$function$
;


CREATE OR REPLACE FUNCTION simbirsoft.createevent(pnameevent text, pdateevent timestamp without time zone, ptimeevent text, pcityid integer, pplace text, pdescription text, pcountpeople integer, pdirectionid integer, pimage text, porganizerid integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
/*
 * Функция для получения создания мероприятия
 * 
 * Функция возвращает таблицу с полями:
 * pnameevent - наименование мероприятия
 * pdateevent - дата проведения мероприятия 
 * ptimeevent - время проведения мероприятия 
 * pcityid - идентификатор города,
 * pplace - место проведения мероприятия,
 * pdescription - описание мероприятия,
 * pcountpeople - ограничение по количеству людей на мероприятии,
 * pdirectionid - идентификатор отдела, 
 * pimage - путь до изображения,
 * porganizerid - идентификатор организатора(создателя) мероприятия
 */
declare 
idevent integer;
begin  
 insert into simbirsoft.events(nameevent, dateevent, timeevent, cityid, place, description, countpeople, directionid, image, organizerid)
 values(pnameevent, pdateevent, ptimeevent, pcityid, pplace, pdescription, pcountpeople, pdirectionid, pimage, porganizerid)
 returning id into idevent;
 --добавление организатора в список участников мероприятия
 insert into simbirsoft.eventsusers(userid, eventid, inqueue, organizer) values(porganizerid, idevent, false, true);
end;
$function$
;


CREATE OR REPLACE FUNCTION simbirsoft.createfeedback(puserid integer, peventid integer, pfeedback text, prating integer default null, pshowfeedback boolean DEFAULT false)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
/*
 * Функция для создания отзыва
 * 
 * Функция возвращает таблицу с полями:
 * puserid - идентификатор участника (равен null, если пользователь хочет оставить отзы анонимно)
 * peventid - идентификатор меропрития
 * pfeedback - отзыв
 * pshowfeedback - показывать отзыв в мероприятии
 * 
 */
declare 
idevent integer;
begin  
 insert into simbirsoft.feedback(userid, eventid, feedback, showfeedback, rating)
 values(puserid, peventid, pfeedback, pshowfeedback, prating);
end;
$function$
;


CREATE OR REPLACE FUNCTION simbirsoft.createmessage(peventid integer, puserid integer, pmessage text)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
/*
 * Функция для сохранения сообщения по идентификатору мероприятия
 * 
 * Входные параметры:
 * peventid - идентификатор меропрития
 * 
 * Функция возвращает сообщения для выбранного мероприятия:
 * ruserid - идентификатор пользователя
 * rusername - фамилия и имя пользователя
 */
begin
	--добавить проверку есть ли у пользователя доступ к данному меропритию, иначе сообщение об ошибке
 insert into simbirsoft.chat(userid, eventid, dtime, message) values(puserid, peventid, clock_timestamp(), pmessage);
end;
$function$
;


CREATE OR REPLACE FUNCTION simbirsoft.deleteuserfromevent(puserid integer, peventid integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
/*
 * Функция для удаления пользователем своей записи на мероприятие
 * 
 * Входные параметры:
 * puserid - идентификатор пользователя
 * peventid - идентификатор мероприятия
 * 
 */
declare
 luserid integer;
begin
  delete from simbirsoft.eventsusers eu
  where eu.userid = puserid and eu.eventid = peventid;
 
  --добавляем пользователя из очереди в мероприятие, если в очереди кто-то есть
 --получаем идентификатор первого в очереди 
 select e.userid 
 into luserid
 from simbirsoft.eventsusers e
 where e.eventid = peventid and e.inqueue = true 
 order by e.registrdate
 limit 1;

 update simbirsoft.eventsusers
 set inqueue = false 
 where eventid = peventid and userid = luserid;
end;
$function$
;


CREATE OR REPLACE FUNCTION simbirsoft.getallmessage(peventid integer)
 RETURNS TABLE(reventid integer, rnameevent text, rusername text, rdtime timestamp without time zone, rmessage text)
 LANGUAGE plpgsql
AS $function$
/*
 * Функция для получения сообщений чата для выбранного мероприятия
 * 
 * Входные параметры:
 * peventid - идентификатор меропрития
 * 
 * Функция возвращает сообщения для выбранного мероприятия:
 * reventid - идентификатор мероприятия, 
 * rnameevent - наименование мероприятия, 
 * rusername - имя фамилия участника отправившего сообщение, 
 * rdtime - дата сообщения,
 * rmessage - текст сообщения
 */
begin
  return query
    select c.eventid, e.nameevent, u.firstname || ' ' || u.lastname as username, c.dtime, c.message
    from simbirsoft.chat c
    left join simbirsoft.events e on c.eventid = e.id 
    left join simbirsoft.userlist u on c.userid = u.userid
    where c.eventid = peventid
    order by c.dtime;
end;
$function$
;


CREATE OR REPLACE FUNCTION simbirsoft.getallparticipants(peventid integer)
 RETURNS TABLE(ruserid integer, rusername text)
 LANGUAGE plpgsql
AS $function$
/*
 * Функция для получения списка участников мероприятия по идентификатору мероприятия
 * 
 * Входные параметры:
 * peventid - идентификатор меропрития
 * 
 * Функция возвращает сообщения для выбранного мероприятия:
 * ruserid - идентификатор пользователя
 * rusername - фамилия и имя пользователя
 */
begin
  return query
    select e.userid, u.firstname || ' ' || u.lastname as username  
    from simbirsoft.eventsusers e
    left join simbirsoft.userlist u on e.userid = u.userid 
    where e.eventid = peventid;
end;
$function$
;


CREATE OR REPLACE FUNCTION simbirsoft.getcity()
 RETURNS TABLE(id integer, name text)
 LANGUAGE plpgsql
AS $function$
/*
 * Функция для получения списка городов
 * 
 * Функция возвращает таблицу с полями:
 * id - иденитификатор города,
 * name - название города
 */
begin
  return query
    select c.id, c.name 
    from simbirsoft.city c;
end;
$function$
;


CREATE OR REPLACE FUNCTION simbirsoft.getcounteventsbydate(pdateevent timestamp without time zone)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
/*
 * Функция для получения списка мероприятий с фильтрацией
 * 
 * Входные параметры:
 * puserid - идентификатор пользователя
 * pdateevent - дата меропрития
 * pcityid - идентификатор города 
 * pdirectionid - идентификатор направления
 * pparticipation - участвую (true - да, false - все мероприятия)
 * pcount - ограничение по количеству участников (true - есть ограничение, false - нет ограничения)
 * 
 * Функция возвращает:
 * 
 */
declare
 c integer;
begin 
    select count(*) as countevents
    into c
    from simbirsoft.events e 
    where e.dateevent::date = pdateevent::date;
   return c;
end;
$function$
;


CREATE OR REPLACE FUNCTION simbirsoft.getdirection()
 RETURNS TABLE(id integer, name text)
 LANGUAGE plpgsql
AS $function$
/*
 * Функция для получения списка отделов
 * 
 * Функция возвращает таблицу с полями:
 * id - идентификатор города,
 * name - название отдела
 */
begin
  return query
    select d.id, d.name 
    from simbirsoft.direction d;
end;
$function$
;


CREATE OR REPLACE FUNCTION simbirsoft.geteventsbydate(pbegdate timestamp without time zone)
 RETURNS TABLE(rnameevent text, rdateevent timestamp without time zone, rtimeevent text, rnamecity text, rplace text, rdescription text, rcountpeople integer, rnamedirection text, rimage text, rusername text)
 LANGUAGE plpgsql
AS $function$
/*
 * Функция для получения списка мероприятий за заданную дату
 * 
 * Входные параметры:
 * pbegdate - дата меропрития
 * 
 * Функция возвращает таблицу с полями:
 * rnameevent - наименование мероприятия,
 * rdateevent - дата начала мероприятия,
 * rtimeevent - время проведения мероприятия,
 * rnamecity - наименование города,
 * rplace - описание места, где проходит мероприятие,
 * rdescription - описание мероприятия,
 * rcountpeople - количество людей,
 * rnamedirection - наименование направления,
 * rimage - изображение,
 * rusername - фамилия и имя организватора мероприятия
 */
begin
  return query
    select e.nameevent,
           e.dateevent,
           e.timeevent,
           c."name",
           e.place,
           e.description,
           e.countpeople,
           d."name",
           e.image,
           u.lastname || ' ' || u.firstname as username
    from simbirsoft.events e
    left join simbirsoft.city c on e.cityid = c.id
    left join simbirsoft.direction d on e.directionid = d.id
    left join simbirsoft.userlist u on e.organizerid = u.userid
    where e.dateevent::date = pbegdate::date;
end;
$function$
;


CREATE OR REPLACE FUNCTION simbirsoft.geteventsbyfilters(puserid integer, pdateevent timestamp without time zone, pcityid integer, pdirectionid integer DEFAULT NULL::integer, pparticipation boolean DEFAULT false, pcount boolean DEFAULT false)
 RETURNS TABLE(reventid integer, rnameevent text, rdateevent timestamp without time zone, rtimeevent text, rnamecity text, rplace text, rdescription text, rcountpeople integer, rnamedirection text, rimage text, rusername text, likeevent boolean)
 LANGUAGE plpgsql
AS $function$
/*
 * Функция для получения списка мероприятий с фильтрацией
 * 
 * Входные параметры:
 * puserid - идентификатор пользователя
 * pdateevent - дата меропрития
 * pcityid - идентификатор города 
 * pdirectionid - идентификатор направления
 * pparticipation - участвую (true - да, false - все мероприятия)
 * pcount - ограничение по количеству участников (true - есть ограничение, false - нет ограничения)
 * 
 * Функция возвращает таблицу с полями:
 * reventid - идентификатор мероприятия
 * rnameevent - наименование мероприятия,
 * rdateevent - дата начала мероприятия,
 * rtimeevent - время проведения мероприятия,
 * rnamecity - наименование города,
 * rplace - описание места, где проходит мероприятие,
 * rdescription - описание мероприятия,
 * rcountpeople - количество людей,
 * rnamedirection - наименование направления,
 * rimage - изображение,
 * rusername - фамилия и имя организватора мероприятия
 * likeevent - понравилось мероприятие (да - true, нет - false)
 */
declare
 larrayevents integer[];
begin
	--получаем список мероприятий в которых участвует пользователь
	select array_agg(eventid) 
	into larrayevents
	from simbirsoft.eventsusers
	where userid = puserid;

  return query 
    select distinct 
           e.id,
           e.nameevent,
           e.dateevent,
           e.timeevent,
           c."name",
           e.place,
           e.description,
           e.countpeople,
           d."name",
           e.image,
           u.lastname || ' ' || u.firstname as username,
           case when f.eventid is null then false else true end as likeevent
    from simbirsoft.events e
    left join simbirsoft.city c on e.cityid = c.id
    left join simbirsoft.direction d on e.directionid = d.id
    left join simbirsoft.userlist u on e.organizerid = u.userid
    left join eventsusers eu on e.id = eu.eventid
    left join simbirsoft.favoriteevents f on f.eventid = e.id and f.userid = puserid
    where e.dateevent::date = pdateevent::date    
    and (c.id = pcityid or pcityid is null)
    and (e.directionid = pdirectionid or pdirectionid is null)
    and (pparticipation = false or e.id in (select unnest(larrayevents)))
    and (pcount = false or countpeople is not null and countpeople <> 0);
end;
$function$
;


CREATE OR REPLACE FUNCTION simbirsoft.geteventsbyid(peventid integer)
 RETURNS TABLE(rnameevent text, rdateevent timestamp without time zone, rtimeevent text, rnamecity text, rplace text, rdescription text, rcountpeople integer, rnamedirection text, rimage text, rusername text, rnumberofvisitors integer)
 LANGUAGE plpgsql
AS $function$
/*
 * Функция для получения информации о мероприятий по идентификатору мероприятия
 * 
 * Входные параметры:
 * peventid - идентификатор меропрития
 * 
 * Функция возвращает таблицу с полями:
 * rnameevent - наименование мероприятия,
 * rdateevent - дата мероприятия,
 * rtimeevent - время проведения мероприятия,
 * rnamecity - наименование города,
 * rplace - описание места, где проходит мероприятие,
 * rdescription - описание мероприятия,
 * rcountpeople - количество людей,
 * rnamedirection - наименование направления,
 * rimage - изображение,
 * rusername - фамилия и имя организватора мероприятия
 * numberofvisitors - количество людей, посетивших мероприятие (если мероприятие ещё не закончилось, то null)
 */
declare
lnumberofvisitors integer;
begin
	select count(*)  
	into lnumberofvisitors
    from simbirsoft.eventsusers e 
   where e.eventid = 1 and inqueue = false and organizer = false;
  
  return query
    select e.nameevent,
           e.dateevent,
           e.timeevent,
           c."name",
           e.place,
           e.description,
           e.countpeople,
           d."name",
           e.image,
           u.lastname || ' ' || u.firstname as username,
           case when clock_timestamp()::date > e.dateevent then lnumberofvisitors else null end as numberofvisitors
    from simbirsoft.events e
    left join simbirsoft.city c on e.cityid = c.id
    left join simbirsoft.direction d on e.directionid = d.id
    left join simbirsoft.userlist u on e.organizerid = u.userid
    where e.id = peventid;
end;
$function$
;


CREATE OR REPLACE FUNCTION simbirsoft.geteventsbyuserid(puserid integer)
 RETURNS TABLE(rid integer, rnameevent text, rdateevent timestamp without time zone, rtimeevent text, rnamecity text, rplace text, rdescription text, rcountpeople integer, rnamedirection text, rimage text, rusername text)
 LANGUAGE plpgsql
AS $function$
/*
 * Функция для получения списка мероприятий на которые записался пользователь
 * 
 * Входные параметры:
 * puserid - идентификатор пользователя
 * 
 * Функция возвращает таблицу с полями:
 * rid - идентификатор мероприятия,
 * rnameevent - наименование мероприятия,
 * rdateevent - дата начала мероприятия,
 * rtimeevent - время проведения мероприятия,
 * rnamecity - наименование города,
 * rplace - описание места, где проходит мероприятие,
 * rdescription - описание мероприятия,
 * rcountpeople - количество людей,
 * rnamedirection - наименование направления,
 * rimage - изображение,
 * rusername - фамилия и имя организатора мероприятия
 */
declare
begin
  return query
  select e.id,
         e.nameevent,
         e.dateevent,
         e.timeevent, 
         c."name",
         e.place,
         e.description,
         e.countpeople,
         d."name",
         e.image,
         u.lastname || ' ' || u.firstname as username 
from simbirsoft.eventsusers eu
left join simbirsoft.events e on eu.eventid = e.id 
left join simbirsoft.city c on e.cityid = c.id
left join simbirsoft.direction d on e.directionid = d.id
left join simbirsoft.userlist u on e.organizerid = u.userid
where eu.userid = puserid and e.dateevent::date >= clock_timestamp()::date;
end;
$function$
;


CREATE OR REPLACE FUNCTION simbirsoft.getfavoriteevents(puserid integer)
 RETURNS TABLE(rnameevent text, rdateevent timestamp without time zone, rtimeevent text, rnamecity text, rplace text, rdescription text, rcountpeople integer, rnamedirection text, rimage text, rusername text)
 LANGUAGE plpgsql
AS $function$
/*
 * Функция для получения списка понравившихся мероприятий
 * 
 * Входные параметры:
 * puserid - идентификатор пользователя
 * 
 * Функция возвращает таблицу с полями:
 * rnameevent - наименование мероприятия,
 * rdateevent - дата начала мероприятия,
 * rtimeevent - дата начала мероприятия,
 * rnamecity - наименование города,
 * rplace - описание места, где проходит мероприятие,
 * rdescription - описание мероприятия,
 * rcountpeople - количество людей,
 * rnamedirection - наименование направления,
 * rimage - изображение,
 * rusername - фамилия и имя организатора мероприятия
 */
declare
begin
  return query
  select e.nameevent,
           e.dateevent,           
           e.timeevent,
           c."name",
           e.place,
           e.description,
           e.countpeople,
           d."name",
           e.image,
           u.lastname || ' ' || u.firstname as username
from simbirsoft.favoriteevents f
left join simbirsoft.events e on f.eventid = e.id 
left join simbirsoft.city c on e.cityid = c.id
left join simbirsoft.direction d on e.directionid = d.id
left join simbirsoft.userlist u on e.organizerid = u.userid
where f.userid = puserid;
end;
$function$
;


CREATE OR REPLACE FUNCTION simbirsoft.getfeedbackbyeventid(peventid integer)
 RETURNS TABLE(rid integer, rnameevent text, rdateevent timestamp without time zone, rtimeevent text, rusername text, rrating integer, rfeedback text)
 LANGUAGE plpgsql
AS $function$
/*
 * Функция для получения отзывов по мероприятию
 * 
 * Входные параметры:
 * puserid - идентификатор пользователя
 * 
 * Функция возвращает таблицу с полями:
 * rid - идентификатор мероприятия,
 * rnameevent - наименование мероприятия,
 * rdateevent - дата начала мероприятия,
 * rtimeevent - время проведения мероприятия,
 * username - имя и фамилия пользователя оставившего отзыв,
 * rating - оценка,
 * feedback - отзыв
 */
declare
begin
  return query
  select e.id, 
         e.nameevent, 
         e.dateevent, 
         e.timeevent, 
         --avg(f.rating) over(partition by f.eventid) as avgrating,
         case when f.userid is not null then u.firstname || ' ' || u.lastname
         else 'Аноним' end as username,
         f.rating,
         f.feedback
  from simbirsoft.events e
  left join simbirsoft.feedback f on f.eventid = e.id 
  left join simbirsoft.userlist u on u.userid = f.userid 
  where e.id = peventid and f.showfeedback = true;
end;
$function$
;


CREATE OR REPLACE FUNCTION simbirsoft.getfeedbackbyuserid(puserid integer)
 RETURNS TABLE(rid integer, rnameevent text, rdateevent timestamp without time zone, rtimeevent text, ravgrating numeric, rusername text, rrating integer, rfeedback text)
 LANGUAGE plpgsql
AS $function$
/*
 * Функция для получения отзывов по мероприятиям, которые организовал пользователь
 * 
 * Входные параметры:
 * puserid - идентификатор пользователя
 * 
 * Функция возвращает таблицу с полями:
 * rid - идентификатор мероприятия,
 * rnameevent - наименование мероприятия,
 * rdateevent - дата начала мероприятия,
 * rtimeevent - время проведения мероприятия,
 * avgrating - средняя оценка,
 * username - имя и фамилия пользователя оставившего отзыв,
 * rating - оценка,
 * feedback - отзыв
 */
declare
begin
  return query
  select e.id, 
         e.nameevent, 
         e.dateevent, 
         e.timeevent, 
         avg(f.rating) over(partition by f.eventid) as avgrating,
         u.firstname || ' ' || u.lastname as username,
         f.rating,
         f.feedback
  from simbirsoft.events e
  left join simbirsoft.feedback f on f.eventid = e.id 
  left join simbirsoft.userlist u on u.userid = f.userid 
  where organizerid = puserid;
end;
$function$
;


CREATE OR REPLACE FUNCTION simbirsoft.getlastevents(puserid integer)
 RETURNS TABLE(rnameevent text, rdateevent timestamp without time zone, rtimeevent text, rnamecity text, rplace text, rdescription text, rcountpeople integer, rnamedirection text, rimage text, rusername text)
 LANGUAGE plpgsql
AS $function$
/*
 * Функция для получения списка прошедших мероприятий
 * 
 * Входные параметры:
 * puserid - идентификатор пользователя
 * 
 * Функция возвращает таблицу с полями:
 * rnameevent - наименование мероприятия,
 * rdateevent - дата начала мероприятия,
 * rtimeevent - дата окончания мероприятия,
 * rnamecity - наименование города,
 * rplace - описание места, где проходит мероприятие,
 * rdescription - описание мероприятия,
 * rcountpeople - количество людей,
 * rnamedirection - наименование направления,
 * rimage - изображение,
 * rusername - фамилия и имя организатора мероприятия
 */
declare
begin
  return query
  select e.nameevent,
         e.dateevent,
         e.timeevent, 
         c."name",
         e.place,
         e.description,
         e.countpeople,
         d."name",
         e.image,
         u.lastname || ' ' || u.firstname as username 
from simbirsoft.eventsusers eu
left join simbirsoft.events e on eu.eventid = e.id 
left join simbirsoft.city c on e.cityid = c.id
left join simbirsoft.direction d on e.directionid = d.id
left join simbirsoft.userlist u on e.organizerid = u.userid
where eu.userid = puserid and e.dateevent::date <= clock_timestamp() and eu.inqueue = false;
end;
$function$
;


CREATE OR REPLACE FUNCTION simbirsoft.userverification(ploginid text, ppassworduser text)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
/*
 * Функция для проверки существует ли такой пользователь в таблице userlist
 * 
 * Входные параметры:
 * ploginid - логин пользователя
 * ppassworduser - пароль пользователя
 * 
 * Функция возвращает true, если такой пользователь существует, иначе false
 */
declare
 c boolean;
begin
	if exists (select * from simbirsoft.userlist u where u.loginid = ploginid and u.passworduser = ppassworduser)
	then return true;
	else return false;
    end if;
  
end;
$function$
;


