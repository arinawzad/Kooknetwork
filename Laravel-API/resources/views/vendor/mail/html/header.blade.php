@props(['url'])
<tr>
<td class="header">
<a href="{{ $url }}" style="display: inline-block;">
@if (trim($slot) === 'kook coin')
<h1>kook coin</h1>
@else
{{ $slot }}
@endif
</a>
</td>
</tr>
