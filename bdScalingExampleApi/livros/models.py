from django.db import models
from datetime import datetime


class Livro (models.Model):
    nome_livro = models.TextField()
    descricao = models.TextField()
    autores = models.TextField()
    categoria = models.CharField(max_length=100)
    data_criacao = models.DateTimeField(default=datetime.now, blank=True)
