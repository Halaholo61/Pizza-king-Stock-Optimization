-- Bahan-bahan yang sering digunakan
SELECT 
    ing.ing_name,
    SUM(o.quantity) AS total_order_quantity
FROM 
    c_orders o
LEFT JOIN 
    c_item i ON i.item_id = o.item_id
LEFT JOIN 
    c_recipe r ON i.sku = r.recipe_id
LEFT JOIN 
    c_ingredients ing ON r.ing_id = ing.ing_id
WHERE 
    ing.ing_name IS NOT NULL
GROUP BY 
    ing.ing_name
ORDER BY 
    total_order_quantity desc;



-- item yang paling laku
SELECT 
    i.sku,
    SUM(o.quantity) AS total_order_quantity
FROM 
    c_orders o
LEFT JOIN 
    c_item i ON i.item_id = o.item_id
LEFT JOIN 
    c_recipe r ON i.sku = r.recipe_id
LEFT JOIN 
    c_ingredients ing ON r.ing_id = ing.ing_id
WHERE 
    ing.ing_name IS NOT NULL
GROUP BY 
    i.sku
ORDER BY 
    total_order_quantity desc;



--Total Penggunaan bahan per Minggu
SELECT 
    ing.ing_name,
    DATEPART(WEEK, DATEADD(WEEK, 1, o.created_at)) AS week_number,
	SUM(o.quantity) AS total_order_quantity,
    SUM(o.quantity*r.quantity) AS total_weight_quantity
FROM 
    c_orders o
LEFT JOIN 
    c_item i ON i.item_id = o.item_id
LEFT JOIN 
    c_recipe r ON i.sku = r.recipe_id
LEFT JOIN 
    c_ingredients ing ON r.ing_id = ing.ing_id
WHERE 
    ing.ing_name IS NOT NULL
GROUP BY 
    ing.ing_name, DATEPART(WEEK, DATEADD(WEEK, 1, o.created_at))
ORDER BY 
    ing.ing_name, DATEPART(WEEK, DATEADD(WEEK, 1, o.created_at));


--menghitung harga bahan pokok
WITH RecipeCost AS (
--menghitung harga bahan
    SELECT 
        r.recipe_id,
        ing.ing_name,
        ing.ing_weight,
        ing.ing_price,
        r.quantity,
        ing.ing_price / ing.ing_weight AS weight_price_pergram,
        (ing.ing_price / ing.ing_weight) * r.quantity AS total_cost_per_recipe
    FROM 
        c_orders o
    LEFT JOIN 
        c_item i ON i.item_id = o.item_id
    LEFT JOIN 
        c_recipe r ON i.sku = r.recipe_id
    LEFT JOIN 
        c_ingredients ing ON r.ing_id = ing.ing_id
    WHERE 
        recipe_id IS NOT NULL
    GROUP BY 
        r.recipe_id,
        r.quantity,
        ing.ing_name,
        ing.ing_weight,
        ing.ing_price
),
TotalProductionCost AS (
    SELECT 
        recipe_id,
        SUM(total_cost_per_recipe) AS total_production_cost
    FROM 
        RecipeCost
    GROUP BY 
        recipe_id
)
SELECT * FROM TotalProductionCost;


--total biaya semua inventory
WITH TotalInventoryCost AS (
-- total biaya per bahan
    SELECT 
        ing.ing_name,
        SUM(ing.ing_price * inv.quantity) AS total_inventory_cost
    FROM 
        c_inventory inv
    LEFT JOIN 
        c_ingredients ing ON inv.item_id = ing.ing_id
    GROUP BY 
        ing.ing_name
)

SELECT 
    SUM(total_inventory_cost) AS total_inventory_cost
FROM 
    TotalInventoryCost;



WITH TotalOrders AS (
--total pengeluaran item perminggu
    SELECT 
        ing.ing_name,
        DATEPART(WEEK, DATEADD(WEEK, 1, o.created_at)) AS week_number,
        SUM(o.quantity) AS total_order_quantity,
        SUM(o.quantity * r.quantity) AS total_weight_quantity
    FROM 
        c_orders o
    LEFT JOIN 
        c_item i ON i.item_id = o.item_id
    LEFT JOIN 
        c_recipe r ON i.sku = r.recipe_id
    LEFT JOIN 
        c_ingredients ing ON r.ing_id = ing.ing_id
	WHERE
		ing.ing_name IS NOT NULL
    GROUP BY 
        ing.ing_name, DATEPART(WEEK, DATEADD(WEEK, 1, o.created_at))
),

TotalInventory AS (
--total inventory
    SELECT 
        ing.ing_name,
        SUM(ing.ing_weight * inv.quantity) AS total_inventory
    FROM 
        c_inventory inv
    LEFT JOIN 
        c_ingredients ing ON inv.item_id = ing.ing_id
    GROUP BY 
        ing.ing_name
)

SELECT 
    ti.ing_name,
    ta.week_number,
    SUM(ti.total_inventory) AS total_inventory,
    SUM(COALESCE(ta.total_weight_quantity, 0)) AS total_weight_quantity,
    SUM(ti.total_inventory - COALESCE(ta.total_weight_quantity, 0)) AS total_remaining_inventory
FROM 
    TotalInventory ti
LEFT JOIN 
    TotalOrders ta ON ti.ing_name = ta.ing_name
GROUP BY 
    ti.ing_name,
    ta.week_number;




select 
*
from
c_orders o
LEFT JOIN 
    c_item i ON i.item_id = o.item_id
LEFT JOIN 
    c_recipe r ON i.sku = r.recipe_id
LEFT JOIN 
    c_ingredients ing ON r.ing_id = ing.ing_id
LEFT JOIN 
    c_inventory inv ON inv.item_id = ing.ing_id
WHERE 
    ing.ing_name IS NOT NULL;