import { Component, Input } from '@angular/core';
import CartProduct from '../../models/cart-product';
import { CartListItemComponent } from '../cart-list-item/cart-list-item.component';
import { MatIconModule } from '@angular/material/icon';

@Component({
  selector: 'app-cart-list',
  imports: [CartListItemComponent, MatIconModule],
  templateUrl: './cart-list.component.html',
  styleUrl: './cart-list.component.css',
})
export class CartListComponent {
  // @Input({ required: true }) cartList: CartProduct[];
  @Input({ required: true }) cartIndex: string;
  constructor() {
    //   this.cartList = [];
    this.cartIndex = '0';
  }
}
