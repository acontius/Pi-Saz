import { Component } from '@angular/core';
import { ProductListItemComponent } from '../product-list-item/product-list-item.component';
import { MatIconModule } from '@angular/material/icon';

@Component({
  selector: 'app-product-list',
  imports: [ProductListItemComponent, MatIconModule],
  templateUrl: './product-list.component.html',
  styleUrl: './product-list.component.css',
})
export class ProductListComponent {
  products: string[] = ['1', '2', '3', '4'];
}
