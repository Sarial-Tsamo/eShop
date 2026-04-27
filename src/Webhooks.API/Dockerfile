FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Set DOTNET_ROOT
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH=/usr/share/dotnet:$PATH

# Copy central package versions
COPY Directory.Packages.props ./

# Copy Webhooks.API project
COPY src/Webhooks.API/Webhooks.API.csproj ./src/Webhooks.API/

# Restore dependencies
RUN dotnet restore ./src/Webhooks.API/Webhooks.API.csproj

# Copy everything
COPY . .

# Publish Webhooks.API
RUN dotnet publish ./src/Webhooks.API/Webhooks.API.csproj \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app

# Set DOTNET_ROOT
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH=/usr/share/dotnet:$PATH

COPY --from=build /app/publish .
EXPOSE 80
ENV ASPNETCORE_URLS=http://+:80
ENV ASPNETCORE_ENVIRONMENT=Production

RUN apt-get update && apt-get install -y libgssapi-krb5-2

ENTRYPOINT ["dotnet", "Webhooks.API.dll"]