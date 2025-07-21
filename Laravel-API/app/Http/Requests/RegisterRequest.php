<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'team_code' => 'nullable|string|size:8', // Optional team code, must be 8 characters if provided
        ];
    }

    /**
     * Get custom error messages for validator errors.
     *
     * @return array
     */
    public function messages(): array
    {
        return [
            'team_code.size' => 'The team code must be exactly 8 characters.',
        ];
    }
}