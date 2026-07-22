-- Hace falta agregar campo public_posicional_accuracy para corte Naturalista

drop table if exists naturalista20241207.tablaunion_valgeo_AvesNaturalista;

create table naturalista20241207.tablaunion_valgeo_AvesNaturalista
SELECT '' as global_unique_identifier,id,null as id_privadas,place_country_name as pais_intacto,place_state_name as estado_intacto,place_admin1_name as admin1_naturalista,place_county_name as municipio_intacto,place_admin2_name as admin2_naturalista,place_guess as localidad_intacta,
place_town_name as town_name_naturalista,latitude as latitud_intacta,longitude as longitud_intacta,coordinates_obscured as coordinates_obscured_naturalista,'naturalista' as proyecto
FROM naturalista20241207.observations_snib o;

ALTER TABLE naturalista20241207.tablaunion_valgeo_AvesNaturalista MODIFY COLUMN global_unique_identifier VARCHAR(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
modify column id bigint(20) DEFAULT null,
MODIFY COLUMN id_privadas bigint(20) DEFAULT null,
MODIFY COLUMN pais_intacto varchar(30) default '',
MODIFY COLUMN estado_intacto varchar(50) default '',
MODIFY COLUMN municipio_intacto varchar(200) default '',
MODIFY COLUMN admin1_naturalista varchar(30) default '',
MODIFY COLUMN admin2_naturalista varchar(80) default '',
MODIFY COLUMN town_name_naturalista varchar(70) default '',
MODIFY COLUMN proyecto varchar(50) default '';


--  Agregamos las coordenadas obscurecidas
insert into naturalista20241207.tablaunion_valgeo_AvesNaturalista(global_unique_identifier,id,id_privadas,pais_intacto,estado_intacto,admin1_naturalista,municipio_intacto,admin2_naturalista,localidad_intacta,town_name_naturalista,latitud_intacta,longitud_intacta,coordinates_obscured_naturalista,proyecto)
SELECT '' as global_unique_identifier,null as id,id as id_privadas,place_country_name as pais_intacto,place_state_name as estado_intacto,'' as admin1_naturalista,place_county_name as municipio_intacto,'' as admin2_naturalista,
private_place_guess as localidad_intacta,'' as town_name_naturalista,if(private_latitude='',null,private_latitude) as latitud_intacta,if(private_longitude='',null,private_longitude) as longitud_intacta,'' as coordinates_obscured_naturalista,'naturalista privadas' as proyecto
FROM naturalista20241207.observations_snib
where (place_country_name like "%Mexico%" or place_country_name='' or place_country_name is null) and coordinates_obscured='true' order by private_longitude,private_latitude;

-- agregamos los registros del corte de averAves, previamente en una sola tabla ya integramos los ejemplares de especies sensibles.
insert into naturalista20241207.tablaunion_valgeo_AvesNaturalista(global_unique_identifier,id,id_privadas,pais_intacto,estado_intacto,admin1_naturalista,municipio_intacto,admin2_naturalista,localidad_intacta,town_name_naturalista,latitud_intacta,longitud_intacta,coordinates_obscured_naturalista,proyecto)
select global_unique_identifier,null as id,null as id_privadas,country as pais_intacto,state as estado_intacto,'' as admin1_naturalista,county as municipio_intacto,'' as admin2_naturalista,
locality as localidad_intacta,'' as town_name_naturalista,latitude as latitud_intacta,longitude as longitud_intacta,'' as coordinates_obscured_naturalista,'averAves' as proyecto
from averaves202506.ebird_snib_jun_2025;

update  averaves202506.marcarSpSensiblesSNIB m inner join naturalista20241207.tablaunion_valgeo_AvesNaturalista t using(global_unique_identifier)
set t.proyecto='averAves sensibles';

-- Buscamos ejemplares del corte naturalista que cuando ingresaron  al snib no tenían coordenadas privadas y en esta entrega ya cuenta con coordenadas privadas.
create table naturalista20241207.obscurecida_ahoraSI_antesNO
select o.id,estadoregistro,proyecto
FROM observations o inner join snib.ejemplar_curatorial e on o.id=e.idejemplaroriginal
inner join snib.proyecto p using(llaveproyecto)
where coordinates_obscured='true' and observacionusoinformacion not like "%Coordenada obscurecida%";

-- Buscamos ejemplares del corte naturalista que cuando ingresaron  al snib tenían coordenadas privadas y en esta entrega ya no cuentan con coordenadas privadas.
create table naturalista20241207.obscurecida_ahoraNO_antesSI
select o.id,estadoregistro,proyecto
FROM observations o inner join snib.ejemplar_curatorial e on o.id=e.idejemplaroriginal
inner join snib.proyecto p using(llaveproyecto)
where if(coordinates_obscured='true','SI','NO')='NO' and observacionusoinformacion like "%Coordenada obscurecida%"; -- no puse where proyecto='Naturalista' porque se cuelga la consulta

delete from obscurecida_ahoraSI_antesNO
where proyecto<>'Naturalista' or estadoregistro<>''; 

delete from naturalista20241207.obscurecida_ahoraNO_antesSI
where proyecto<>'Naturalista' or estadoregistro<>'';

alter table naturalista20241207.obscurecida_ahoraNO_antesSI add primary key(id);

alter table naturalista20241207.obscurecida_ahoraSI_antesNO add primary key(id);

insert into naturalista20241207.tablaunion_valgeo_AvesNaturalista(global_unique_identifier,id,id_privadas,pais_intacto,estado_intacto,admin1_naturalista,municipio_intacto,admin2_naturalista,localidad_intacta,town_name_naturalista,latitud_intacta,longitud_intacta,coordinates_obscured_naturalista,proyecto);
SELECT '' as global_unique_identifier,o.id,null as id_privadas,place_country_name as pais_intacto,place_state_name as estado_intacto,place_admin1_name as admin1_naturalista,place_county_name as municipio_intacto,place_admin2_name as admin2_naturalista,place_guess as localidad_intacta,
place_town_name as town_name_naturalista,latitude as latitud_intacta,longitude as longitud_intacta,coordinates_obscured as coordinates_obscured_naturalista,'naturalista' as proyecto
FROM naturalista20241207.observations o inner join naturalista20241207.obscurecida_ahoraNO_antesSI a using(id);

insert into naturalista20241207.tablaunion_valgeo_AvesNaturalista(global_unique_identifier,id,id_privadas,pais_intacto,estado_intacto,admin1_naturalista,municipio_intacto,admin2_naturalista,localidad_intacta,town_name_naturalista,latitud_intacta,longitud_intacta,coordinates_obscured_naturalista,proyecto);
SELECT '' as global_unique_identifier,null as id,o.id as id_privadas,place_country_name as pais_intacto,place_state_name as estado_intacto,'' as admin1_naturalista,place_county_name as municipio_intacto,'' as admin2_naturalista,
private_place_guess as localidad_intacta,'' as town_name_naturalista,if(private_latitude='',null,private_latitude) as latitud_intacta,if(private_longitude='',null,private_longitude) as longitud_intacta,'' as coordinates_obscured_naturalista,'naturalista privadas' as proyecto
FROM naturalista20241207.observations o inner join naturalista20241207.obscurecida_ahoraSI_antesNO a using(id)
where (place_country_name like "%Mexico%" or place_country_name='' or place_country_name is null) and coordinates_obscured='true';

 

call snib.13_NullAVacio_tabla('naturalista202404','tablaunion_valgeo_AvesNaturalista');

alter table naturalista20241207.tablaunion_valgeo_AvesNaturalista add column llaveagrupado2024 varchar(32),add column llavecomparaPEMavesnat varchar(32) not null default '';

update naturalista20241207.tablaunion_valgeo_AvesNaturalista
set llavecomparaPEMavesnat=MD5(concat(if(pais_intacto is null or pais_intacto='','pais_intacto',pais_intacto),
if(estado_intacto is null or estado_intacto='','estado_intacto',estado_intacto),
if(admin1_naturalista is null or admin1_naturalista='','admin1_naturalista',admin1_naturalista),
if(municipio_intacto is null or municipio_intacto='','municipio_intacto',municipio_intacto),
if(admin2_naturalista is null or admin2_naturalista='','admin2_naturalista',admin2_naturalista)));

update naturalista20241207.tablaunion_valgeo_AvesNaturalista
set llavecomparaLocAvesNat=MD5(concat(if(localidad_intacta is null or localidad_intacta='','localidad_intacta',localidad_intacta),
if(town_name_naturalista is null or town_name_naturalista='','town_name_naturalista',town_name_naturalista)));

update naturalista20241207.tablaunion_valgeo_AvesNaturalista
set llaveagrupado2024=MD5(concat(llavecomparaPEMavesnat,pais_intacto,estado_intacto,admin1_naturalista,municipio_intacto,admin2_naturalista,llavecomparaLocAvesNat,localidad_intacta,town_name_naturalista,ifnull(latitud_intacta,'latitud'),ifnull(longitud_intacta,'longitud'),coordinates_obscured_naturalista,proyecto));

create table naturalista20241207.tablaunion_valgeo_AvesNaturalista_agrupado
select llaveagrupado2024,llavecomparaPEMavesnat,pais_intacto,estado_intacto,admin1_naturalista,municipio_intacto,admin2_naturalista,llavecomparaLocAvesNat,localidad_intacta,town_name_naturalista,latitud_intacta,longitud_intacta,coordinates_obscured_naturalista,proyecto,count(1) as ejemplares
from naturalista20241207.tablaunion_valgeo_AvesNaturalista
group by llaveagrupado2024;