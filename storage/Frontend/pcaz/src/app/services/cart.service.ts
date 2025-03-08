import { Injectable } from '@angular/core';
import cartProduct from '../models/cart-product';
import Product from '../models/product';

@Injectable({
  providedIn: 'root',
})
export class CartService {
  private cartItems: Map<number, cartProduct> = new Map<number, cartProduct>();

  constructor() {}

  getItems(): cartProduct[] {
    return Array.from(this.cartItems.values());
  }

  addItem(item: Product): number {
    const ref = this.cartItems.get(item.id);
    if (ref === undefined) {
      this.cartItems.set(item.id, { product: item, count: 1 });
      return 1; // New item added
    } else {
      ref.count++; // Increment count
      return ref.count; // Return updated count
    }
  }

  removeItem(item: Product): number {
    const ref = this.cartItems.get(item.id);
    if (ref === undefined) {
      return 0; // Item not found
    }
    if (ref.count === 1) {
      this.cartItems.delete(item.id); // Remove item from cart
      return 0; // Item removed
    }
    ref.count--; // Decrement count
    return ref.count; // Return updated count
  }

  getCount(item: Product): number {
    const ref = this.cartItems.get(item.id);
    return ref ? ref.count : 0; // Return count or 0 if not found
  }
}
