// app.component.ts
import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  Validators,
  ReactiveFormsModule,
} from '@angular/forms';

@Component({
  selector: 'app-root',
  imports: [ReactiveFormsModule, CommonModule],
  templateUrl: './user-data.component.html',
  styleUrls: ['./user-data.component.css'],
})
export class UserDataComponent {
  userForm: FormGroup;
  addressFieldcount: number;
  userData = {
    firstName: 'John',
    lastName: 'Doe',
    phone: '123-456-7890',
    province: 'Ontario',
    address: '123 Main St, Toronto',
  };

  constructor(private fb: FormBuilder) {
    this.addressFieldcount = 1;
    this.userForm = this.fb.group({
      firstName: [''],
      lastName: [''],
      phone: [''],
      province: [''],
      address: [''],
    });
  }

  ngOnInit(): void {
    this.userForm.patchValue(this.userData);
  }

  onSubmit(): void {
    console.log(this.userForm.value);
  }

  addAddressField() {
    ++this.addressFieldcount;
  }
}
