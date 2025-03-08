import { Component, Input } from '@angular/core';
import Product from '../../models/product';
// import { CartService } from '../../services/cart.service';

@Component({
  selector: 'app-product-list-item',
  imports: [],
  templateUrl: './product-list-item.component.html',
  styleUrl: './product-list-item.component.css',
})
export class ProductListItemComponent {
  product: Product;
  constructor() {
    this.product = {
      id: 0,
      img: '',
      name: 'name',
      price: 0,
      count: 5,
    };
  }
  onIncrement(): void {
    // this.product.count = this.cartService.addItem(this.product);
  }

  onDecrement(): void {
    // this.product.count = this.cartService.removeItem(this.product);
  }
}
