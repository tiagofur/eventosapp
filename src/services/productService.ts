import { supabase } from '../lib/supabase';
import { Database } from '../types/supabase';

type Product = Database['public']['Tables']['products']['Row'];
type ProductInsert = Database['public']['Tables']['products']['Insert'];
type ProductUpdate = Database['public']['Tables']['products']['Update'];
type ProductIngredientInsert = Database['public']['Tables']['product_ingredients']['Insert'];

export const productService = {
  async getAll() {
    const { data, error } = await supabase
      .from('products')
      .select('*')
      .order('name');
    
    if (error) throw error;
    return data;
  },

  async getById(id: string) {
    const { data, error } = await supabase
      .from('products')
      .select('*')
      .eq('id', id)
      .single();
    
    if (error) throw error;
    return data;
  },

  async create(product: ProductInsert) {
    const { data, error } = await supabase
      .from('products')
      .insert(product)
      .select()
      .single();
    
    if (error) throw error;
    return data;
  },

  async update(id: string, product: ProductUpdate) {
    const { data, error } = await supabase
      .from('products')
      .update(product)
      .eq('id', id)
      .select()
      .single();
    
    if (error) throw error;
    return data;
  },

  async delete(id: string) {
    const { error } = await supabase
      .from('products')
      .delete()
      .eq('id', id);
    
    if (error) throw error;
  },

  async addIngredients(productId: string, ingredients: { inventoryId: string, quantityRequired: number }[]) {
    if (ingredients.length === 0) return;

    const records: ProductIngredientInsert[] = ingredients.map(i => ({
      product_id: productId,
      inventory_id: i.inventoryId,
      quantity_required: i.quantityRequired
    }));
    
    const { error } = await supabase
      .from('product_ingredients')
      .insert(records);
      
    if (error) throw error;
  },

  async getIngredients(productId: string) {
    const { data, error } = await supabase
      .from('product_ingredients')
      .select(`
        *,
        inventory (ingredient_name, unit, unit_cost)
      `)
      .eq('product_id', productId);
      
    if (error) throw error;
    return data;
  },

  async getIngredientsForProducts(productIds: string[]) {
    if (productIds.length === 0) return [];

    const { data, error } = await supabase
      .from('product_ingredients')
      .select(`
        *,
        inventory (ingredient_name, unit, unit_cost)
      `)
      .in('product_id', productIds);

    if (error) throw error;
    return data || [];
  },

  async updateIngredients(productId: string, ingredients: { inventoryId: string, quantityRequired: number }[]) {
      // Delete existing ingredients for this product
      const { error: deleteError } = await supabase
        .from('product_ingredients')
        .delete()
        .eq('product_id', productId);
        
      if (deleteError) throw deleteError;
      
      // Add new ingredients
      return this.addIngredients(productId, ingredients);
  }
};
