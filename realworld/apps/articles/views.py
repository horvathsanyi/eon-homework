from django.shortcuts import redirect
from django.views.generic import (
    ListView,
    DetailView,
    CreateView,
    UpdateView,
    DeleteView
)

from taggit.models import Tag

from realworld.core.mixins import LoginRequiredMixin, AuthorRequiredMixin
from realworld.apps.comments.forms import Comment, CommentForm

from .forms import Article, ArticleForm


class ArticleListView(ListView):
    model = Article
    context_object_name = "articles"
    template_name = "realworld/articles/article_list.html"

    def get_queryset(self):
        queryset = (super().get_queryset()
                    .select_related("author")
                    .with_favorites(self.request.user)
                    .prefetch_related("tags")
                    .order_by("-created"))

        if tag := self.request.GET.get("tag"):
            return queryset.filter(tags__name__in=[tag])

        if self.request.user.is_authenticated and "own" in self.request.GET:
            return queryset.filter(author=self.request.user)

        return queryset

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context["tags"] = Tag.objects.all()
        return context


class ArticleDetailView(DetailView):
    model = Article
    context_object_name = "article"
    template_name = "realworld/articles/article_detail.html"

    def get_queryset(self):
        queryset = (super().get_queryset()
                    .select_related("author")
                    .with_favorites(self.request.user))
        return queryset

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context["is_following"] = self.object.author.followers.filter(pk=self.request.user.id).exists()
        context["comments"] = (Comment.objects.filter(article=self.kwargs['pk'])
                               .select_related("author")
                               .order_by("-created"))

        if self.request.user.is_authenticated:
            context.update(
                {
                    "comment_form": CommentForm(),
                }
            )
        return context


class ArticleCreateView(AuthorRequiredMixin, CreateView):
    model = Article
    form_class = ArticleForm
    template_name = 'realworld/articles/article_form.html'

    def form_valid(self, form):
        article = form.save(commit=False)
        article.author = self.request.user
        article.save()

        # save tags
        form.save_m2m()

        return super().form_valid(form)


class ArticleUpdateView(AuthorRequiredMixin, UpdateView):
    model = Article
    form_class = ArticleForm
    template_name = 'realworld/articles/article_form.html'


class ArticleDeleteView(AuthorRequiredMixin, DeleteView):
    model = Article
    success_url = '/'


class ArticleFavoriteView(LoginRequiredMixin, UpdateView):
    model = Article
    fields = ["favorites"]
    http_method_names = ["post"]

    def get_queryset(self):
        return (super().get_queryset()
                .select_related("author")
                .exclude(author=self.request.user))

    def post(self, request, *args, **kwargs):
        self.object = self.get_object()
        if self.object.favorites.filter(id=request.user.id).exists():
            self.object.favorites.remove(request.user)
        else:
            self.object.favorites.add(request.user)

        return redirect(self.object.get_absolute_url())
