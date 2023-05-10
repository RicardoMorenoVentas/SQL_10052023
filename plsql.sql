-- función sin parametro de entrada para devolver el precio máximo
CREATE OR REPLACE FUNCTION get_precio_maximo() RETURNS numeric LANGUAGE plpgsql AS $$
	DECLARE
		precio_max numeric;
	BEGIN
		SELECT MAX(unit_price)
		INTO precio_max
		FROM products;
		RETURN precio_max;		
END;$$

SELECT get_precio_maximo();

DO $$
	BEGIN
		RAISE NOTICE 'El precio máximo es de: %',get_precio_maximo();
END $$ LANGUAGE 'plpgsql';

-- Obtener el numero de ordenes por empleado por parametro de entrada
CREATE OR REPLACE FUNCTION get_number_emp(num_empleado int) RETURNS int LANGUAGE plpgsql AS $$
	DECLARE
		cantidad_ordenes int;
	BEGIN
		SELECT COUNT(order_id)
		INTO cantidad_ordenes
		FROM orders
		WHERE employee_id = num_empleado;
		RETURN cantidad_ordenes;		
END;$$

SELECT get_number_emp(5);

DO $$
	DECLARE
		num_empleado integer := 4;
	BEGIN
		RAISE NOTICE 'La cantidad de ordenes del empleado % es de %',num_empleado,get_number_emp(num_empleado);
END $$ LANGUAGE 'plpgsql';

-- Obtener la venta de un empleado con un determinado producto (Cantidad)

CREATE OR REPLACE FUNCTION get_ord_emp_prod(num_empleado int, id_producto int) RETURNS int LANGUAGE plpgsql AS $$
	DECLARE
		get_cant_ordenes int;
	BEGIN
		SELECT COUNT(ord.order_id)
		INTO get_cant_ordenes
		FROM orders ord
		INNER JOIN order_details det
		ON ord.order_id = det.order_id
		WHERE ord.employee_id = num_empleado
		AND det.product_id = id_producto;
		RETURN get_cant_ordenes;
END;$$

SELECT get_ord_emp_prod(4,11);

SELECT get_ord_emp_prod(id_producto => 11, num_empleado => 4);

DO $$
	DECLARE
		id_empleado int := 4;
		id_producto int := 11;
	BEGIN
		RAISE NOTICE 'El empleado % con el producto % ha realizado % ventas',id_empleado,id_producto,get_ord_emp_prod(id_empleado,id_producto);
END $$ LANGUAGE 'plpgsql';

-- Ejemplo retorno tabla

SELECT * FROM orders;
DROP FUNCTION prueba_retorno_tabla;
CREATE OR REPLACE FUNCTION prueba_retorno_tabla() RETURNS TABLE(orderid smallint, customerid varchar, employeeid smallint) LANGUAGE plpgsql AS $$
	BEGIN
		RETURN QUERY
			SELECT
				order_id,
				customer_id,
				employee_id
			FROM orders;
END;$$

SELECT * FROM prueba_retorno_tabla();

-- Crear una funcion para devolver una tabla con producto_id, nombre, precio y unidades en strock, debe obtener los productos terminados en n

CREATE OR REPLACE FUNCTION retorno_productos() RETURNS TABLE(productid smallint, productname varchar, unitprice real, units_stock smallint) LANGUAGE plpgsql AS $$
	BEGIN
		RETURN QUERY
			SELECT
				product_id,
				product_name,
				unit_price,
				units_in_stock
			FROM products
			WHERE product_name LIKE '%n';
END;$$

SELECT * FROM retorno_productos();

-- Creamos la función contador_ordenes_anio() QUE CUENTE LAS ORDENES POR AÑO devuelve una tabla con año y contador
-- 3. Lo mismo que el ejemplo anterior pero con un parametro de entrada que sea el año
SELECT * FROM orders;
CREATE OR REPLACE FUNCTION contador_ordenes_anio(anio int) RETURNS TABLE(cantidadordenes bigint) LANGUAGE plpgsql AS $$
	BEGIN
		RETURN QUERY
			SELECT COUNT(order_id)
			FROM orders
			WHERE EXTRACT(year FROM order_date) = anio;
END;$$

CREATE OR REPLACE FUNCTION contador_ordenes_anio() RETURNS TABLE(anioord numeric, cantidadordenes bigint) LANGUAGE plpgsql AS $$
	BEGIN
		RETURN QUERY
			SELECT 
				EXTRACT(year FROM order_date) AS yr,
				COUNT(order_id)
			FROM orders
			GROUP BY yr
			ORDER BY yr;
END;$$

SELECT * FROM contador_ordenes_anio();
SELECT * FROM contador_ordenes_anio(1997);

-- 4. --PROCEDIMIENTO (Es función, procedimiento no devuelve nada) ALMACENADO PARA OBTENER PRECIO PROMEDIO Y SUMA DE UNIDADES EN STOCK POR CATEGORIA
SELECT * FROM products;
DROP FUNCTION promedio_unidades_categoria;
CREATE OR REPLACE FUNCTION promedio_unidades_categoria(id_categoria integer) RETURNS TABLE(categoriaid smallint, promedio double precision, suma bigint) LANGUAGE plpgsql AS $$
	BEGIN
		RETURN QUERY
			SELECT category_id, AVG(unit_price), SUM(units_in_stock)
			FROM products
			WHERE category_id = id_categoria
			GROUP BY category_id;
END;$$

SELECT * FROM promedio_unidades_categoria(4);
